class Bike {

    private String serialNumber; private String model;

    private double price;

    public Bike(String serialNumber, String model, double price) { this.serialNumber = serialNumber;
        this.model = model; this.price = price;
    }

    public String getSerialNumber() { return serialNumber;
    }
    public void setSerialNumber(String serialNumber) { this.serialNumber = serialNumber;
    }

    public String getModel() { return model;
    }

    public void setModel(String model) { this.model = model;
    }

    public double getPrice() { return price;
    }

    public void setPrice(double price) { this.price = price;
    }
}


class BikeFactory {

    private int totalBikesProduced;

    private Bike[] bikesArr;

    public BikeFactory(int capacity){ this.bikesArr = new Bike[capacity]; this.totalBikesProduced = 0;
    }


    public int getTotalBikesProduced() { return totalBikesProduced;
    }

    public void setTotalBikesProduced(int totalBikesProduced) { this.totalBikesProduced = totalBikesProduced;
    }

    public void produceBike(String model, double price){ if(getTotalBikesProduced() < (365*12/1.5)) {
        setTotalBikesProduced(getTotalBikesProduced() + 1); int b = getTotalBikesProduced() - 1;
        this.bikesArr[b] = new Bike("bike_" + b, model, price);
    }
    else System.out.println("Sorry, too many bikes!");
    }
}
public class BikeTest {
    public static void main(String[] args) { int bikesNo;
        BikeFactory factory = new BikeFactory(10);

    }

}

