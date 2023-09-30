# The script is divided into two parts. The first part contains the set up of the data base and upload of data. 
# The second part contains the analysis of the data and  machine learning models.


#Part 1: Set up of data base

import pandas as pd
from sqlalchemy import create_engine, Column, Integer, String, Date, Numeric
from sqlalchemy.orm import declarative_base
from sqlalchemy.orm import sessionmaker

# Create a MySQL engine
engine = create_engine("mysql+mysqldb://{user}:{pw}@localhost/{db}"
                       .format(user="root",
                               pw="12345",
                               db="bank_analytics"))


#Create a base class for declarative models
Base = declarative_base()

# Define a model for the table
class MyTable(Base):
    __tablename__ = 'dkb'

    id = Column(Integer, primary_key=True)
    buchungstag = Column(Date)
    wertstellung = Column(Date)
    buchungstext = Column(String(255))
    auftraggeber_beguenstigter = Column(String(255))
    verwendungszweck = Column(String(255))
    kontonummer = Column(String(255))
    blz = Column(String(255))
    betrag = Column(Numeric(12, 4))
    glaeubiger_id = Column(String(255))
    mandatsreferenz = Column(String(255))
    kundenreferenz = Column(String(255))
    kategorie = Column(String(255))
# Create the table
Base.metadata.create_all(engine)

# Create a session
Session = sessionmaker(bind=engine)
session = Session()



# CSV file path
dkb_file = '/Users/philipp/Documents/GitHub/sample_projects/bank_analytics/dkb_file.csv'


# Read the CSV file using Pandas
df = pd.read_csv(dkb_file, delimiter=',')


# Rename the headers (column names)
new_headers = ['buchungstag', 'wertstellung', 'buchungstext','auftraggeber_beguenstigter', 'verwendungszweck', 'kontonummer','blz', 'betrag', 'glaeubiger_id', 'mandatsreferenz','kundenreferenz', 'kategorie']  # Provide the new header names in the desired order

df = df.rename(columns=dict(zip(df.columns, new_headers)))

df = df.drop('Unnamed: 11', axis=1)

df['betrag'] = df['betrag'].str.replace('.', '', regex=False)
df['betrag'] = df['betrag'].str.replace(',', '.', regex=False).astype(float)



# Function to cut the size of a string
def cut_string(string, max_length):
    if len(string) <= max_length:
        return string
    else:
        return string[:max_length]

# Specify the maximum length for the string
max_length = 255

# Apply the cut_string function to the 'Name' column
df['verwendungszweck'] = df['verwendungszweck'].apply(cut_string, args=(max_length,))


# Create a table in the database using SQL Alchemy
df.to_sql('dkb', con=engine, if_exists='append', index=False)


# Perform a select query
results = session.query(MyTable).all()

# Print the retrieved rows
for row in results:
    print(row.id, row.buchungstag, row.buchungstext, row.betrag)

# Close the database connection
engine.dispose()




