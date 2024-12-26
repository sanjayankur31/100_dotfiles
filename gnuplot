# From http://labs.guidolin.net/2010/03/how-to-create-beautiful-gnuplot-graphs.html
set macro

# Use podo by default, load others if required in script files
# https://www.nature.com/articles/nmeth.1618
set colorsequence podo

# https://github.com/Gnuplotting/gnuplot-palettes
# load '/home/asinha/Documents/02_Code/00_mine/gnuplot-palettes/moreland.pal'

my_font = "Roboto, "

my_line_width = "2"
my_axis_width = "1.5"
my_ps = "1.2"

# define the font for the terminal
set term qt enhanced font my_font
#set term pngcairo font my_font

# set default point size
set pointsize my_ps

# this is to use the user-defined styles we just defined: deprecated
# set style increment user

# set the text color and font for the label
set label font my_font

# set the color and width of the axis border
set border 31 lw @my_axis_width

# function to check if a file exists
file_exists(file) = system("[ -f '".file."' ] && echo '1' || echo '0'") + 0
