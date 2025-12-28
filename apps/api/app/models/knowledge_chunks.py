from uuid import uuid4
from sqlalchemy import (
    Column,
    String,
    DateTime,
    ForeignKey,
    Integer,
    Text,
    JSON,
    func,
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from base import Base


class KnowledgeChunk(Base):
    """
    Chunks of framework knowledge used for retrieval (RAG).
    """
    __tablename__ = "knowledge_chunks"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid4)

    framework_id = Column(
        UUID(as_uuid=True),
        ForeignKey("frameworks.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    framework_document_id = Column(
        UUID(as_uuid=True),
        ForeignKey("framework_documents.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    # Where this chunk came from in the source document
    source_locator = Column(String, nullable=True)     # e.g. "p12" or "p12-13" or "section 3.2"
    source_path = Column(String, nullable=True)        # e.g. "Data > Modelling > Level 4"

    # Parsed / extracted framework semantics (optional but useful)
    skill_code = Column(String, nullable=True, index=True)   # e.g. "PROG" (SFIA)
    skill_name = Column(String, nullable=True, index=True)   # e.g. "Programming / software development"
    level = Column(String, nullable=True, index=True)        # keep string to support "L4" or "Level 4"

    # Content fields
    title = Column(String, nullable=True)
    raw_text = Column(Text, nullable=False)
    summary_text = Column(Text, nullable=True)

    # Vector indexing bookkeeping (supports per-framework isolation)
    vector_backend = Column(String, nullable=False, default="qdrant")
    vector_collection = Column(String, nullable=False)       # e.g. "sfia_v8"
    vector_id = Column(String, nullable=False, unique=True)  # id in the vector DB

    # Optional: store embedding params for reproducibility
    embedding_model = Column(String, nullable=True)
    embedding_dim = Column(Integer, nullable=True)

    # Any extra metadata you want to persist from LLM extraction
    extra_metadata = Column(JSON, nullable=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)

    framework = relationship("Framework")
    document = relationship("FrameworkDocument")

