package control;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class Conexao {

    private static final String IP = "127.0.0.1";
    private static final String URL = "jdbc:mysql://" + IP + ":3306/controlefinancas?useUnicode=true&characterEncoding=UTF-8";
    private static final String USER = "adminuser";
    private static final String PASSWORD = "senhaforte123";

    private static Connection connection = null;

    public static Connection getConnection() {
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(URL, USER, PASSWORD);
    } catch (ClassNotFoundException | SQLException e) {
        System.err.println("Erro ao conectar: " + e);
        return null;
    }
}

    static Connection getConexao() {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }


    // Método para estabelecer a conexão
    private Conexao() {
        // Construtor privado para evitar instanciação externa
    }

    public static Connection conectar() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(URL, USER, PASSWORD);
            //save(con.toString());
        } catch (ClassNotFoundException | SQLException e) {
            System.err.println("Erro ao conectar: " + e);
        }
        return connection;
    }

    // Método para fechar a conexão
    public static void desconectar(Connection con) {
        if (con != null) {
            try {
                System.out.println("Fechar a conexão: ");
                con.close();
            } catch (SQLException e) {
                System.err.println("Erro ao fechar a conexão: " + e);
            }
        }
    }
    public static void main(String[] args) {
        System.out.println( conectar());
    }

}
