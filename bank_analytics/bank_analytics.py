from sqlalchemy import create_engine

import pandas as pd

conn = create_engine("mysql+mysqldb://userid:12345@localhost/bank_analytics")


try:    
    q="CREATE TABLE IF NOT EXISTS `dkb2` (buchungstag DATE,	wertstellung DATE,	buchungstext VARCHAR(255),	auftraggeber_beguenstigter VARCHAR(255),	verwendungszweck VARCHAR(255),	kontonummer VARCHAR(255),	blz VARCHAR(255),	betrag DOUBLE(24,2), 	glaeubiger_id VARCHAR(255),	mandatsreferenz	VARCHAR(255), kundenreferenz VARCHAR(255))) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;"
   
    conn.execute(q)

except Exception as e:
        error = str(e.__dict__['orig'])
        print(error)


#import of csv file into data frame 
#df = pd.read_csv('dkb_file.csv')


"""
try:

    #create table for each bank 
    mydb = con.connect(
    host="localhost",
    user="root",
    password="12345",
    database="bank_analytics"
    )

    mycursor = mydb.cursor()

    mycursor.execute("CREATE TABLE IF NOT EXISTS dkb (buchungstag DATE,	wertstellung DATE,	buchungstext VARCHAR(255),	auftraggeber_beguenstigter VARCHAR(255),	verwendungszweck VARCHAR(255),	kontonummer VARCHAR(255),	blz VARCHAR(255),	betrag DOUBLE(24,2), 	glaeubiger_id VARCHAR(255),	mandatsreferenz	VARCHAR(255), kundenreferenz VARCHAR(255))")

    print("Tabelle dkb erstellt")



except Exception as e:
    mydb.close()
    print(str(e))
"""

