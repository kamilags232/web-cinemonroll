package persistencia;

import java.sql.Connection;
import java.sql.PreparedStatement;

public class VendaLancheDAO {

    public static void persistir(int recibo, int cdLanche, int quantidade, double valorParcial) throws Exception {
        String sql = "INSERT INTO rl_venda_lanche (nr_recibo, cd_lanche, quantidade, valor_parcial) VALUES (?, ?, ?, ?)";
        BancoDeDados db = new BancoDeDados();

        try (Connection conn = db.conectar();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, recibo);
            ps.setInt(2, cdLanche);
            ps.setInt(3, quantidade);
            ps.setDouble(4, valorParcial);

            ps.executeUpdate();
        }
    }
}
