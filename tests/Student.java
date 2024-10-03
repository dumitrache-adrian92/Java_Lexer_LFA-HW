class Person {
    private String name;
    private int age;

    // constructor
    public Person(String name, int age) { this.name = name;
        this.age = age;
    }

    public void displayInfo() {
        System.out.println("Name: " + name + ", Age: " + age);
    }
}

public class Student {
    private String nume;
    private int varsta;

    public Student() {
        this.nume = "None";
        this.varsta = 0;
    }

    public static void main(String[] args) {
        Student[] studenti = new Student[10];

        for (int i = 0; i < studenti.length; i++) {
            studenti[i] = new Student();
        }

        for (Student student : studenti) {
            System.out.println("Nume: " + student.nume + ", Varsta: " + student.varsta);
        }
    }
}
