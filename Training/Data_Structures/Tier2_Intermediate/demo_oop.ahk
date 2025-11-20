; Demo OOP Pattern
; Demonstrates object-oriented programming in AutoHotkey v2

#Requires AutoHotkey v2.0

; Base class for shapes
class Shape {
    __New(color) {
        this.color := color
    }

    ; Abstract method (to be overridden)
    GetArea() {
        throw Error("GetArea must be implemented by subclass")
    }

    ; Common method
    Describe() {
        return "A " . this.color . " shape with area " . this.GetArea()
    }
}

; Rectangle class
class Rectangle extends Shape {
    __New(color, width, height) {
        super.__New(color)
        this.width := width
        this.height := height
    }

    GetArea() {
        return this.width * this.height
    }
}

; Circle class
class Circle extends Shape {
    static PI := 3.14159

    __New(color, radius) {
        super.__New(color)
        this.radius := radius
    }

    GetArea() {
        return Circle.PI * this.radius * this.radius
    }
}

; Demo usage
DemoOOP() {
    ; Create objects
    rect := Rectangle("Red", 10, 5)
    circle := Circle("Blue", 7)

    ; Use polymorphism
    shapes := [rect, circle]

    result := "Shape Demonstrations:`n`n"
    for index, shape in shapes {
        result .= index . ". " . shape.Describe() . "`n"
    }

    MsgBox(result, "OOP Demo")
}

; Run demo
DemoOOP()
