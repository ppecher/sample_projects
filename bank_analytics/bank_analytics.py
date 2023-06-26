import pandas as pd
from sqlalchemy import create_engine, Column, Integer, String, Date
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
    buchungstext = Column(String(50))
    auftraggeber_beguenstigter = Column(String(50))
    verwendungszweck = Column(String(50))
    kontonummer = Column(String(50))
    blz = Column(String(50))
    betrag = Column(Integer)
    glaeubiger_id = Column(String(50))
    mandatsreferenz = Column(String(50))

# Create the table
Base.metadata.create_all(engine)

# Create a session
Session = sessionmaker(bind=engine)
session = Session()



# CSV file path
dkb_file = '/Users/philipp/Documents/GitHub/sample_projects/bank_analytics/dkb_file.csv'


# Read the CSV file using Pandas
df = pd.read_csv(dkb_file)

# Create a table in the database using SQL Alchemy
df.to_sql('dkb', con=engine, if_exists='append', index=False)


# Perform a select query
results = session.query(MyTable).all()

# Print the retrieved rows
for row in results:
    print(row.id, row.buchungstag, row.buchungstext, row.betrag)

# Close the database connection
engine.dispose()



