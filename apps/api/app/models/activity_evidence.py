from uuid import uuid4
from sqlalchemy import (
    Column,
    String,
    DateTime,
    ForeignKey,
    Float,
    Text,
    JSON,
    func,
)
from sqlalchemy.dialects.postgresql import UUID, ARRAY
from sqlalchemy.orm import relationship

from base import Base


class ActivityEvidence(Base):
    """
    Evidence linking an activity to one framework skill/level with traceability.
    """
    __tablename__ = "activity_evidence"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid4)

    activity_id = Column(
        UUID(as_uuid=True),
        ForeignKey("activities.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    framework_id = Column(
        UUID(as_uuid=True),
        ForeignKey("frameworks.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    # What skill this evidence supports (normalized from the framework KB)
    skill_code = Column(String, nullable=True, index=True)
    skill_name = Column(String, nullable=False, index=True)
    level = Column(String, nullable=True, index=True)

    # LLM output fields
    confidence = Column(Float, nullable=True)  # 0..1
    justification = Column(Text, nullable=False)

    # Traceability: which chunks were used to support this mapping
    supporting_chunk_ids = Column(ARRAY(UUID(as_uuid=True)), nullable=True)

    # Reproducibility / audits
    llm_model = Column(String, nullable=True)
    prompt_version = Column(String, nullable=True)
    analysis_run_id = Column(UUID(as_uuid=True), nullable=True)  # tie multiple rows to one run

    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    activity = relationship("Activity")
    framework = relationship("Framework")
