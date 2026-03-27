package persistencia;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class BancoDeDados {
    public Connection conectar() throws SQLException { 
        return DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/bd_cinema?" + 
            "user=root&password=09031993y&serverTimezone=UTC&useSSL=false"
        );
    }
   
}