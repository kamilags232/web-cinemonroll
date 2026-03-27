package negocio;

import java.time.LocalDateTime;
import java.math.BigDecimal;
import persistencia.VendaDAO;

public class Venda {
    
    private int nrRecibo;
    private int cdCliente;
    private LocalDateTime dtHrVenda;
    private BigDecimal valorTotal;
    private String tpPagamento;

    public Venda() {}

    public Venda(int cdCliente, BigDecimal total, String tpPagamento){
        this.cdCliente = cdCliente;
        this.valorTotal = total;
        this.tpPagamento = tpPagamento;
    }

    public int getNrRecibo() {
        return nrRecibo;
    }

    public void setNrRecibo(int nrRecibo) {
        this.nrRecibo = nrRecibo;
    }

    public int getCdCliente() {
        return cdCliente;
    }

    public LocalDateTime getDtHrVenda() {
        return dtHrVenda;
    }

    public BigDecimal getValorTotal() {
        return valorTotal;
    }

    public String getTpPagamento() {
		return tpPagamento;
	}

	public void setTpPagamento(String tpPagamento) {
		this.tpPagamento = tpPagamento;
	}

	public int persistir() throws Exception {
        return new VendaDAO().persistir(this);
    }
}
