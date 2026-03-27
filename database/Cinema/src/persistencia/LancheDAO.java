package persistencia;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import negocio.Lanche;

public class LancheDAO {

    public static List<Lanche> listar() throws Exception {
        String sql = "SELECT cd_lanche, lanche, valor_lanche FROM tb_lanche";
        BancoDeDados db = new BancoDeDados();

        List<Lanche> lista = new ArrayList<>();

        try (Connection conn = db.conectar();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                lista.add(new Lanche(
                    rs.getInt("cd_lanche"),
                    rs.getString("lanche"),
                    rs.getBigDecimal("valor_lanche")
                ));
            }
        }

        return lista;
    }
}
