package com.ceron.adapter;

import com.ceron.service.EmployeeService;
import com.ceron.service.database.EmployeeDatabaseService;
import com.ceron.model.Employee;

public class EmployeeDatabaseAdapter implements EmployeeService {
    private EmployeeDatabaseService databaseService;

    public EmployeeDatabaseAdapter() {
        this.databaseService = new EmployeeDatabaseService();
    }

    @Override
    public Employee getEmployeeById(int id) {
        return databaseService.findEmployeeByCode(id);
    }
}
