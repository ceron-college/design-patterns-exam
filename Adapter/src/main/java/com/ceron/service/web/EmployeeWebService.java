package com.ceron.service.web;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import org.json.JSONObject;
import com.ceron.model.Employee;

public class EmployeeWebService {

    private static final String API_BASE_URL = "https://api-rest-adapter.onrender.com";

    public Employee getEmployee(int employeeId) {
        Employee employee = null;
        try {
            String urlString = API_BASE_URL + "/employee/" + employeeId;
            URL url = new URL(urlString);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("Accept", "application/json");

            if (conn.getResponseCode() != 200) {
                System.out.println("Failed : HTTP error code : " + conn.getResponseCode());
                return null;
            }

            BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            StringBuilder sb = new StringBuilder();
            String output;
            while ((output = br.readLine()) != null) {
                sb.append(output);
            }

            conn.disconnect();

            JSONObject json = new JSONObject(sb.toString());
            employee = new Employee(
                    json.getInt("id"),
                    json.getString("name"),
                    json.getDouble("salary"),
                    json.getString("role"),
                    json.getString("tech"),
                    json.getString("email")
            );

        } catch (Exception e) {
            e.printStackTrace();
        }
        return employee;
    }
}
