#### Generator toa automatically fill the visitor.db with random
# visitors and visits

import names

from randomtimestamp import randomtimestamp
import sqlite3

conn = sqlite3.connect('visitor.db')
c = conn.cursor()
conn.row_factory = sqlite3.Row

for i in range(1,1000):
    
    fname_i = names.get_first_name()
    sname_i = names.get_last_name()
    email_i = fname_i + sname_i +"@gmail.com"
    print(fname_i + " " + sname_i)
    
    time1_i = randomtimestamp(2020, False)
    time2_i  = randomtimestamp(2020, False)
    
    if time1_i <= time2_i:
        arrival = time1_i 
        depature = time2_i
    else:
        arrival = time2_i
        depature = time1_i
        
    print(arrival)
    print(depature)
    
    c.execute("INSERT INTO visitor VALUES (?,?,?,?)", (None, fname_i, sname_i, email_i))
    
    c.execute("SELECT visitor_id FROM visitor ORDER by visitor_id DESC ")
           
    i = c.fetchone()
    visitor_id = ''.join(map(str, i))

    
    c.execute("INSERT INTO visit VALUES (?,?,?)", (visitor_id, arrival, depature))
    
conn.commit() 








