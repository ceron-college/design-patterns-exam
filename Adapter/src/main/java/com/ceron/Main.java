package com.ceron;

import com.ceron.service.EmployeeService;
import com.ceron.adapter.EmployeeDatabaseAdapter;
import com.ceron.adapter.EmployeeWebServiceAdapter;
import com.ceron.model.Employee;

public class Main {
    public static void main(String[] args) {
        int employeeId = 1;

        // Using Database Service
        EmployeeService dbAdapter = new EmployeeDatabaseAdapter();
        Employee employeeFromDb = dbAdapter.getEmployeeById(employeeId);
        System.out.println("Employee from Database: " + employeeFromDb);

        // Using Web Service
        EmployeeService webAdapter = new EmployeeWebServiceAdapter();
        Employee employeeFromWeb = webAdapter.getEmployeeById(employeeId);
        System.out.println("Employee from Web Service: " + employeeFromWeb);
    }
}
