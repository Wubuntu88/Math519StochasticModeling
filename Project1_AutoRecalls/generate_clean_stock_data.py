#!/usr/bin/python
import re as re

stock_file_name = 'toyota_stock.txt'
f_read = open('zstock_data_dirty/' + stock_file_name, 'r')

lines_to_write = ["Date\tPrice"]

for line in f_read:
    comps = line.split("}, ")
    date_string = re.sub('[{,]', '', comps[0]).strip()
    price_string = comps[1].replace("}", "").strip()
    lines_to_write.append(date_string + "\t" + price_string)

contents_to_write = "\n".join(lines_to_write)

f_write = open('zstock_data_clean/' + stock_file_name, 'w')
f_write.write(contents_to_write)

f_read.close()
f_write.close()
