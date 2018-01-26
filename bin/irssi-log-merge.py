#!/usr/bin/python
# .- coding: utf-8 -.
# irssi-log-merge.py.
# Written by Lasse Karstensen <lasse.karstensen@gmail.com>, 2008. 
# Released under GPLv2.
#
# Newest version available on http://hyse.org/irssi-log-merge/ .

import os, sys, glob, shutil, codecs

def usage():
    print "irssi-log-merge.py by <lasse.karstensen@gmail.com>"
    print "Usage: %s [opts] todir dir1 dir2 <dir3...>" % sys.argv[0]
    print ""
    print "Sorts irssi log files chronologically from dir[123..] into todir."
    print "Directories should contain subdirectories like 'EFNet','IRCNet'..." 
    print "Use -f to overwrite existing files in todir, if file size differ."
    print "Use -F to overwrite existing files in todir no matter what."
    print ""

class IrssiLogReader():
    import time, codecs
    def __init__(self):
        self.linebuf = ''
        self.sessionbuf = ''
        self.files = {}
        
    def addfile(self, filename):
        self.files [ filename ] = { 
                                'fp': self.codecs.open(filename, 'r+'), 
                                'time': None,
                                'closed': False,
                                'buffer': u'' }

    def run(self, output):
        if len(self.files) == 0:
            raise Exception, 'No files to parse'

        pref = None
        def handle_charset(bytestr):
            # http://evanjones.ca/python-utf8.html
            # let's just assume utf8 first, and change it into latin1
            # if there is any sign of it.
            charset = 'utf-8'
            # search for latin-1 bytes of norwegian ae, oe, aa.
            # lower first, then upper case.
            #latin1chars = ['\xe6','\xf8','\xe5','\xc6','\xd8','\xc5']
            # from the list at 
            # http://en.wikipedia.org/wiki/ISO/IEC_8859-1#ISO-8859-1
            # the chars from 160-255 are pretty much printable.

            # handle_charset() is called very many times during 
            # execution. Expanding the list to keep chr() from being
            # run a few hundred thousand times. 
            # latin1chars = [ chr(x) for x in range(160,255+1) ]
            latin1chars = ['\xa0', '\xa1', '\xa2', '\xa3', '\xa4', '\xa5', '\xa6',
            '\xa7', '\xa8', '\xa9', '\xaa', '\xab', '\xac', '\xad',
            '\xae', '\xaf', '\xb0', '\xb1', '\xb2', '\xb3', '\xb4',
            '\xb5', '\xb6', '\xb7', '\xb8', '\xb9', '\xba', '\xbb',
            '\xbc', '\xbd', '\xbe', '\xbf', '\xc0', '\xc1', '\xc2',
            '\xc3', '\xc4', '\xc5', '\xc6', '\xc7', '\xc8', '\xc9',
            '\xca', '\xcb', '\xcc', '\xcd', '\xce', '\xcf', '\xd0',
            '\xd1', '\xd2', '\xd3', '\xd4', '\xd5', '\xd6', '\xd7',
            '\xd8', '\xd9', '\xda', '\xdb', '\xdc', '\xdd', '\xde',
            '\xdf', '\xe0', '\xe1', '\xe2', '\xe3', '\xe4', '\xe5',
            '\xe6', '\xe7', '\xe8', '\xe9', '\xea', '\xeb', '\xec',
            '\xed', '\xee', '\xef', '\xf0', '\xf1', '\xf2', '\xf3',
            '\xf4', '\xf5', '\xf6', '\xf7', '\xf8', '\xf9', '\xfa',
            '\xfb', '\xfc', '\xfd', '\xfe', '\xff']

            for char in latin1chars: 
                # used to prefix common utf-8 double-byte chars.
                if char == '\xc3':
                    continue
                if char in bytestr:
                    found_at = bytestr.find(char)
                    if bytestr[found_at - 1] == '\xc3':
                        # neitakk
                        continue
                    #print "%s (%s) found at %i" % (char, hex(ord(char)), bytestr.find(char))
                    charset = 'latin-1'
                    break

            # urk. minor hardcoded hack. 
            bytestr = bytestr.replace("\xc3\x65", "\x65")

            try:
                bytestr = bytestr.decode(charset, 'replace')
            except Exception, e:
                print dump(bytestr)
                print "handle_charset: ", e
                raise Exception
            return bytestr

        while True:
            # find the earliest file
            if not pref:
                t1 = None
                for filename, fdict in self.files.items():
                    # if the file is empty, don't bother trying to read from
                    # it.
                    if fdict["closed"]:
                        #print "file %s is closed, and not eligiable for election" % filename
                        continue

                    l = fdict["fp"].readline()

                    l = handle_charset(l)

                    fdict["buffer"] += l
                    if l.startswith('--- Log opened'):
                        datestring = " ".join(l.split()[3:])
                        try:
                            dt = self.parse_timestamp( datestring )
                        except ValueError, e:
                            # So. This is usually where the badness
                            # occurs. So. We handle it with grace, and
                            # dump the problematic log lines into a new
                            # file that can be read later.
                            # 
                            # Easter egg!
                            print "ERROR: ValueError when parsing timestamp."
                            if "dump" in filename:
                                print "Seems to already be reading a dump file, not replacing dump"
                            else:
                                dumpfile = "fault/EFNet/dump"
                                import os.path
                                if not os.path.isdir(os.path.dirname(dumpfile)):
                                    print "Directory %s does not exist. Create it to get a dump of exception cause." % ( os.path.dirname(dumpfile))
                                    raise ValueError, e
                                ff = self.codecs.open(dumpfile, "w+", 'utf-8')
                                ff.write( l )
                                # cheat, to make it parseable
                                ff.write("--- Log closed\n")
                                ff.close()
                                print "Troublesome log dumped to file %s" % dumpfile
                            raise ValueError, e
                        fdict["time"] = dt
                        #print "file %s has datestring %s" % (filename, dt)
                      
                # see if we're done.
                active = []
                for filename, fdict in self.files.items():
                    if not fdict["closed"]:
                        active.append(filename)
                if len(active) == 0:
                    #print "No more data to read"
                    return 
                # loop through all files and find the one with the earliest
                # timestamp.
                for filename, fdict in self.files.items():
                    if fdict["closed"]:
                        continue

                    #print "File: %s\ttimestamp: %s" % (filename, fdict["time"])
                    if t1 == None:
                        t1 = fdict["time"]

                    if fdict["time"] <= t1:
                        t1 = fdict["time"]
                        pref = filename
                #print "Finished electing. file %s. ts=%s, pref: %s" % (filename, t1,  pref)

            #print "dumping block from file %s (ts: %s)" % (pref, self.files[pref]["time"])
            while True:
                # we may have cached data for this file, read while
                # seeking for the next Log started line. Dump this
                # first.
                if len(self.files[pref]["buffer"]) > 0:
                    l = self.files[pref]["buffer"]
                    self.files[pref]["buffer"] = u''
                else:
                    l = self.files[pref]["fp"].readline()
                    l = handle_charset(l)
                    #print type(l), dump(l)
                    if len(l) == 0:
                        #print "end of file %s, forcing new election" % filename
                        self.files[pref]["closed"] = True
                        pref = None
                        break

                try: 
                    output.write( l )
                except UnicodeEncodeError, e:
                    print type(l), dump(l)
                    print e
                    raise Exception

                if l.startswith('--- Log closed'):
                    #print "end of block, forcing new election"
                    pref = None
                    break

    def parse_timestamp(self, timestring):
        # from http://www.python.org/doc/2.5.2/lib/node745.html :
        # .. If, when coding a module for general use, you need a locale
        # independent version of an operation that is affected by the
        # locale (such as string.lower(), or certain formats used with
        # time.strftime()), you will have to find a way to do it without
        # using the standard library routine. Even better is convincing
        # yourself that using locale settings is okay. Only as a last
        # resort should you document that your module is not compatible
        # with non-"C" locale settings.
        #
        # So, here we go. :(
        # --- Log opened Tue Mar 28 21:17:38 2006
        # datetime(year, month, day[, hour[, minute[, second[, microsecond[,tzinfo]]]]])
        # en: Sun Oct 15 23:58:13 2006
        # >>> time.strftime("%a %b %d %H:%M:%S %Y", time.localtime())
        # 'Mon Nov 17 17:47:16 2008'
        # 'tor mar 29 13:16:47 2007' - norwegian day names used. replace
        # enough so that strptime can recognize it as english.
        # 
        # TODO: We have the month, the year and the date. We don't need
        # to bother transforming and parsing the day name, as it is a
        # function of the mentioned three. Remove it some time.
        tdata = """
# notation hell. format: tovalue = from1,from2..
mon = man, ma. 
tue = tir, ti.
wed = ons, on.
thu = tor, to.
fri = fre, fr.
# latin-1
#sat = lør
#sun = søn
#sat = l\xf8r, l\xf8.
#sun = s\xf8n, s\xf8.
sat = lør, lø.
sun = søn, sø.
#, s\xc3\xb8n
#
apr = april
may = mai
jun = juni, jun.
jul = juli, jul.
aug = aug.
sep = sep.
oct = oct., okt, okt.
nov = nov.
dec = des"""
        format  = '%a %b %d %H:%M:%S %Y'
        transforms = {}
        for t in tdata.split("\n"):
            if len(t) == 0:
                continue
            if t[0] == "#":
                continue

            (tovalue, keys) = t.split("=", 1)
            if not "," in keys:
                keys = [ keys ]
            else:
                keys = keys.split(",")

            for key in keys:
                key = unicode(key, 'utf-8')
                transforms[ key.strip() + " " ] = tovalue.strip() + " "
        s = None

        for fromkey, tovalue in transforms.items():
            #print fromkey, tovalue
            i = timestring.find(fromkey)
            if i > -1:
                #print "performing transform %s->%s" % (fromkey, tovalue)
                timestring = timestring.replace(fromkey, tovalue)

        s = self.time.strptime(timestring, format)
        return s 

# following three procedures are stolen from
# http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/142812 Jack
# Trainor 2008
""" dump any string to formatted hex output """
def dump(s):
    import types
    if type(s) == types.StringType:
        return dumpString(s)
    elif type(s) == types.UnicodeType:        
        return dumpUnicodeString(s)

#FILTER = ''.join([(len(repr(chr(x))) == 3) and chr(x) or '.' for x in range(256)])

""" dump any string, ascii or encoded, to formatted hex output """
def dumpString(src, length=16):
    result = []
    for i in xrange(0, len(src), length):
       chars = src[i:i+length]
       hex = ' '.join(["%02x" % ord(x) for x in chars])
       printable = ''.join(["%s" % ((ord(x) <= 127 and FILTER[ord(x)]) or '.') for x in chars])
       result.append("%04x  %-*s  %s\n" % (i, length*3, hex, printable))
    return ''.join(result)

""" dump unicode string to formatted hex output """
def dumpUnicodeString(src, length=8):
    result = []
    for i in xrange(0, len(src), length):
       unichars = src[i:i+length]
       hex = ' '.join(["%04x" % ord(x) for x in unichars])
       printable = ''.join(["%s" % ((ord(x) <= 127 and FILTER[ord(x)]) or '.') for x in unichars])
       result.append("%04x  %-*s  %s\n" % (i*2, length*5, hex, printable))
    return ''.join(result)

def find_networks(paths):
    known_networks = {}
    for dir in paths:
        for ent in glob.glob(dir + "/*"):
            if not os.path.isdir(ent):
                continue
            networkname = os.path.basename(ent) 
            if not known_networks.has_key(networkname):
                known_networks[ networkname ] = []
            known_networks[ networkname ].append( ent )
    return known_networks

def main():
    if len(sys.argv) < 3:
        usage()
        sys.exit(255)

    # not very nice, but using getopt is a bit overkill.
    force = False
    forcefull = False
    if "-f" in sys.argv:
        force = True
        print "Replacing files in todir if size is incorrect"
        sys.argv.pop( sys.argv.index("-f") )

    if "-F" in sys.argv:
        forcefull = True
        force = True
        print "Overwriting old files in todir unconditionally"
        sys.argv.pop( sys.argv.index("-F") )
        
    todir = sys.argv[1]
    dirs = sys.argv[2:]

    if not os.path.isdir(todir):
        os.makedirs(todir)

    known_networks = find_networks(dirs)
    sources = {}

    for network, paths in known_networks.items():
        # TODO: irssi sometimes create a second network instance, 
        # after wrong use of /connect and such. Perhaps one day one
        # should try to merge these with the original. 
        #if network.endswith("2"):
        #    continue

        #print "finding available sources in network %s\t" % network,
        for path in paths:
            for file in glob.glob(path + '/*'):
                if not os.path.isfile(file):
                    continue
                (network, id) = file.split(os.sep)[-2:]
                fullid = network + "/" + id
                if not sources.has_key(fullid):
                    sources[fullid] = []
                sources[fullid] += [ file ]
    
    for source, files in sources.items():
        #print "source: %s" % source
        tofile = os.path.join(todir, source)
        if not os.path.isdir(os.path.dirname(tofile)):
            os.makedirs(os.path.dirname(tofile))

        if os.path.isfile(tofile) and not forcefull:
            srcsize = 0
            for srcfile in files:
                srcsize += os.stat(srcfile)[5]
            if os.stat(tofile)[5] == srcsize:
                print "Existing file %s has size equal to size of sources. Assuming file is already sorted. (-F to override)" % tofile
                continue

            if not force:
                print "File %s already exist. Not overwriting. Do you need -f?" % tofile
                continue

        if len(files) == 1:
            print "File %s only exist in one source, copying.." % source
            shutil.copy(files[0], tofile)
            continue

        print "Merging source %s with files: %s" % (source, " ".join(files))

        fp = codecs.open(tofile, 'w+', 'utf-8')

        lr = IrssiLogReader()
        for file in files:
            lr.addfile(file)
        lr.run(output=fp)
        fp.close()
    print "All files successfully merged, normal exit"


if __name__ == "__main__":
    main()
