package apresentacao;

import java.io.IOException;
import java.math.BigDecimal;

import jakarta.servlet.annotation.*;
import jakarta.servlet.http.*;
import negocio.Ingresso;
import negocio.Pessoa;
import negocio.Venda;
import persistencia.PessoaDAO;
import persistencia.VendaDAO;

@WebServlet("/finalizarCompra")
public class VendaServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws IOException {

        try {
            // ► CLIENTE
            Pessoa p = new Pessoa();
            p.setCliente(request.getParameter("nome"));
            p.setEmail(request.getParameter("email"));
            p.setCpf(request.getParameter("cpf"));
            int cdCliente = new PessoaDAO().persistir(p);

            // ► VENDA
            BigDecimal valor = new BigDecimal(request.getParameter("valorFinal"));
            String pagamento = request.getParameter("pagamento");

            Venda v = new Venda(cdCliente, valor, pagamento);
            int recibo = v.persistir();

            // ► INGRESSO
            Ingresso i = new Ingresso(
                request.getParameter("assento"),
                Integer.parseInt(request.getParameter("cdSessao")),
                recibo
            );
            i.persistir();

            // ► LANCHES opcionais
            String[] lanches = request.getParameterValues("lanches");

            if(lanches != null){
                VendaDAO vd = new VendaDAO();
                for(String lanche : lanches){
                    vd.inserirLanche(recibo, Integer.parseInt(lanche));
                }
            }

            if(p.getCpf().equals("___.___.___-__")) p.setCpf(null);

            response.setStatus(200);
            response.getWriter().write("OK");

        } catch (Exception e) {
            response.setStatus(500);
            response.getWriter().write("ERRO: " + e.getMessage());
        }
    }
}
