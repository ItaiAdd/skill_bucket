from uuid import uuid4
from sqlalchemy import Column, String, DateTime, Date, Text, func
from sqlalchemy.dialects.postgresql import UUID
from base import Base

class Activity(Base):
    __tablename__ = "activities"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid4)

    title = Column(String, nullable=False)
    description = Column(Text, nullable=False)
    project = Column(String, nullable=True)
    date_started = Column(Date, nullable=True)
    date_ended = Column(Date, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)

