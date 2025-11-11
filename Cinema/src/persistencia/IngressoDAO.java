package persistencia;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import negocio.Ingresso;

public class IngressoDAO {

    public void persistir(Ingresso obj) throws Exception {
        String sql = "INSERT INTO tb_ingresso (valor_ingresso, assento, tp_ingresso, cd_sessao, nr_recibo) "
                   + "VALUES ( ?, ?, ?, ?, ?)";

        BancoDeDados db = new BancoDeDados();

        try (Connection conn = db.conectar();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setBigDecimal(1, new java.math.BigDecimal("20.00")); // valor padrão do ingresso
            ps.setString(2, obj.getAssento());
            ps.setString(3, "normal"); // tipo de ingresso default
            ps.setInt(4, obj.getCdSessao());
            ps.setInt(5, obj.getNrRecibo());

            ps.executeUpdate();
        }
    }
    
    public static boolean assentoOcupado(String assento, int cdSessao) throws Exception {
        String sql = "SELECT 1 FROM tb_ingresso WHERE assento = ? AND cd_sessao = ?";
        BancoDeDados db = new BancoDeDados();

        try (Connection conn = db.conectar();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, assento);
            ps.setInt(2, cdSessao);

            ResultSet rs = ps.executeQuery();
            return rs.next(); // se encontrar, é true = ocupado
        }
    }

}
