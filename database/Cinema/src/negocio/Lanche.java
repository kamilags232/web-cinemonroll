package negocio;

import java.math.BigDecimal;

public class Lanche {
    private int cdLanche;
    private String nome;
    private BigDecimal valor;

    public Lanche() {}

    public Lanche(int cdLanche, String nome, BigDecimal valor) {
        this.cdLanche = cdLanche;
        this.nome = nome;
        this.valor = valor;
    }

    public int getCdLanche() {
        return cdLanche;
    }

    public void setCdLanche(int cdLanche) {
        this.cdLanche = cdLanche;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public BigDecimal getValor() {
        return valor;
    }

    public void setValor(BigDecimal valor) {
        this.valor = valor;
    }
}
