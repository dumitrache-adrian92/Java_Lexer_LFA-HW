public class MemoryAllocation {
    public static void main(String[] args) {
        int[] intArray = new int[10];
        int[] intArray2 = new int[10];
        String[] stringArray = new String[5];
        Employee e1 = new Employee(1);
        Employee e2 = new Employee(2);

    }
}

class Employee {
    // class member variable
    private int empId;
    private String empName;
    private String empDesignation;
    private String empCompany;

    public Employee(int eId) {
        this.empId = eId;
    }

    public int getEmpId() {
        return empId;
    }

    public void setEmpId(int empId) {
        this.empId = empId;
    }

    public String getEmpName() {
        return empName;
    }

    public void setEmpName(final String eName) {
        if (eName == null || eName.length() <= 0) {
            throw new IllegalArgumentException();
        }
    }

    public String getEmpDesignation() {
        return empDesignation;
    }

    public void setEmpDesignation(final String eDesignation) {
        this.empDesignation = eDesignation;
    }

    public String getEmpCompany() {
        return empCompany;
    }

    public void setEmpCompany(final String eCompany) {
        this.empCompany = eCompany;
    }

}
