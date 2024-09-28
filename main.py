from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

import models, schemas
from database import engine, get_db

models.Base.metadata.create_all(bind=engine)

app = FastAPI()

@app.post("/courses/", response_model=schemas.Course)
def create_course(course: schemas.CourseCreate, db: Session = Depends(get_db)):
    db_course = models.Course(**course.dict())
    db.add(db_course)
    db.commit()
    db.refresh(db_course)
    return db_course

@app.get("/courses/", response_model=List[schemas.Course])
def get_courses(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    courses = db.query(models.Course).offset(skip).limit(limit).all()
    return courses

@app.get("/courses/{course_id}", response_model=schemas.Course)
def get_course(course_id: int, db: Session = Depends(get_db)):
    print(f"Attempting to find course with id: {course_id}")
    course = db.query(models.Course).filter(models.Course.id == course_id).first()
    if course is None:
        print(f"No course found with id: {course_id}")
        # Let's check if there are any courses in the database
        all_courses = db.query(models.Course).all()
        print(f"Total courses in database: {len(all_courses)}")
        if all_courses:
            print("IDs of available courses:", [c.id for c in all_courses])
        raise HTTPException(status_code=404, detail=f"Course with id {course_id} not found")
    print(f"Found course: {course.name}")
    return course

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)