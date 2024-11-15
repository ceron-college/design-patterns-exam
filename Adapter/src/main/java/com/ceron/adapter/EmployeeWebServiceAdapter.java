package com.ceron.adapter;

import com.ceron.service.EmployeeService;
import com.ceron.service.web.EmployeeWebService;
import com.ceron.model.Employee;

public class EmployeeWebServiceAdapter implements EmployeeService {
    private EmployeeWebService webService;

    public EmployeeWebServiceAdapter() {
        this.webService = new EmployeeWebService();
    }

    @Override
    public Employee getEmployeeById(int id) {
        return webService.getEmployee(id);
    }
}
