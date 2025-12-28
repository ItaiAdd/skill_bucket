from sqlalchemy import Column, String, DateTime, UUID, Date
from base import Base

class Activity(Base):
    """
    Model for activities.
    """
    __tablename__ = "activities"

    id = Column(UUID(), primary_key=True)
    title = Column(String(), nullable=False)
    description = Column(String(), nullable=False)
    date = Column(Date(), nullable=True)
    date_added = Column(DateTime(), nullable=False)
    