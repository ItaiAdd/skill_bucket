from uuid import uuid4
from sqlalchemy import (
    Column,
    String,
    DateTime,
    ForeignKey,
    BigInteger,
    Text,
    func
    )
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from base import Base

class Framework(Base):
    __tablename__ = "frameworks"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid4)

    name = Column(String, nullable=False)
    version = Column(String, nullable=True)

    description = Column(Text, nullable=False)
    license = Column(String, nullable=True)
    homepage_url = Column(String, nullable=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)

    documents = relationship("FrameworkDocument", back_populates="framework", cascade="all, delete-orphan")


class FrameworkDocument(Base):
    __tablename__ = "framework_documents"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid4)

    framework_id = Column(UUID(as_uuid=True), ForeignKey("frameworks.id", ondelete="CASCADE"), nullable=False)

    title = Column(String, nullable=True)
    description = Column(Text, nullable=True)

    doc_type = Column(String, nullable=False)           # e.g. "pdf", "docx"
    content_type = Column(String, nullable=True)        # e.g. "application/pdf"
    storage_backend = Column(String, nullable=False, default="minio")
    bucket = Column(String, nullable=False)
    object_key = Column(String, nullable=False)

    size_bytes = Column(BigInteger, nullable=True)
    checksum = Column(String, nullable=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    uploaded_at = Column(DateTime(timezone=True), nullable=True)

    framework = relationship("Framework", back_populates="documents")