from pydantic import BaseModel

class CourseBase(BaseModel):
    name: str
    description: str
    duration: int

class CourseCreate(CourseBase):
    pass

class Course(CourseBase):
    id: int

    class Config:
        from_attributes = True  # This replaces orm_mode = True