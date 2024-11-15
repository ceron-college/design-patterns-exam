package com.ceron.model;

public class Employee {
    private int id;
    private String name;
    private double salary;
    private String role;
    private String tech;
    private String email;

    public Employee() {}

    public Employee(int id, String name, double salary, String role, String tech, String email) {
        this.id = id;
        this.name = name;
        this.salary = salary;
        this.role = role;
        this.tech = tech;
        this.email = email;
    }

    // Getters and Setters

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public double getSalary() { return salary; }
    public void setSalary(double salary) { this.salary = salary; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getTech() { return tech; }
    public void setTech(String tech) { this.tech = tech; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    @Override
    public String toString() {
        return "Employee [id=" + id + ", name=" + name + ", salary=" + salary +
                ", role=" + role + ", tech=" + tech + ", email=" + email + "]";
    }
}
