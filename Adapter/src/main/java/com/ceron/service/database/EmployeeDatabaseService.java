package com.ceron.service.database;

import java.sql.*;
import com.ceron.model.Employee;

public class EmployeeDatabaseService {
    // Hardcoded database connection details
    private static final String DB_URL = "jdbc:postgresql://dpg-csrdlu56l47c73fcvpbg-a.oregon-postgres.render.com:5432/postgresql_adapter";
    private static final String USER = "postgresql_adapter_user";
    private static final String PASS = "HYt5R1BrJuzfVQ6w460ZXIMREPxfcnPV";

    public Employee findEmployeeByCode(int code) {
        Employee employee = null;
        String query = "SELECT * FROM employees WHERE id = ?";

        try (Connection conn = DriverManager.getConnection(DB_URL, USER, PASS);
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setInt(1, code);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                employee = new Employee(
                        rs.getInt("id"),
                        rs.getString("name"),
                        rs.getDouble("salary"),
                        rs.getString("role"),
                        rs.getString("tech"),
                        rs.getString("email")
                );
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return employee;
    }
}
