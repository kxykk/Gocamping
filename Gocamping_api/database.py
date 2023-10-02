#database.py
from sqlalchemy import create_engine, MetaData
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base

DATABASE_URL = "mysql+pymysql://root:kpxi0919@localhost:3306/gocamping"

engine = create_engine(DATABASE_URL,
                       pool_size=10, 
                        max_overflow=10000)
metadata = MetaData()

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()
