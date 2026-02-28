from sqlalchemy import create_engine
from sqlalchemy.orm import scoped_session, sessionmaker

from .base import Base
from .activities import Activity
from .activity_evidence import ActivityEvidence
from .frameworks import Framework, FrameworkDocument
from .knowledge_chunks import KnowledgeChunk


def _create_engine(dburi, echo=True):
    return create_engine(dburi, echo=echo, pre_ping_pool=True)


def db_session(engine, autocommit=False, autoflush=False):
    return scoped_session(
        sessionmaker(bind=engine, autocommit=autocommit, autoflush=autoflush)
    )


def init_db(dburi, echo=True):
    engine = _create_engine(dburi, echo=echo)
    Base.metadata.create_all(bind=engine)