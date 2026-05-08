import time
import random
import psycopg2
from faker import Faker

db_config = {
    'dbname': 'liga_sudoers',
    'user': 'sudoers',    
    'password': 'sudoers',
    'host': 'localhost',
    'port': '5432'
}

fake = Faker('pt_BR')

def insert_pessoa(cursor):
    id_pessoa = random.randint(10000000000, 99999999999)
    nome = fake.name()
    sexo = 'F' if nome.split()[0][-1] == 'a' else 'M'
    dt_nasc = fake.date_of_birth(minimum_age=18, maximum_age=60)
    
    cursor.execute("INSERT INTO pessoas (id, nome, sexo, dt_nasc, created_at) VALUES (%s, %s, %s, %s, NOW());", 
                   (id_pessoa, nome, sexo, dt_nasc))
    print(f"✅ INSERT (CDC 'c'): Novo cliente inserido -> {id_pessoa} | {nome}")

def update_pessoa(cursor):
    # Pega um cliente aleatório
    cursor.execute("SELECT id, nome FROM pessoas ORDER BY random() LIMIT 1;")
    res = cursor.fetchone()
    if res:
        pessoa_id, nome_antigo = res
        novo_nome = fake.name() + " (Atualizado)"
        cursor.execute("UPDATE pessoas SET nome = %s, updated_at = NOW() WHERE id = %s;", (novo_nome, pessoa_id))
        print(f"🔄 UPDATE (CDC 'u'): Cliente {pessoa_id} atualizado. De '{nome_antigo}' para '{novo_nome}'")

def delete_pessoa(cursor):
    # Procura um cliente que NÃO tenha pedidos para não dar erro de Chave Estrangeira (IntegrityError)
    cursor.execute("""
        SELECT p.id, p.nome FROM pessoas p 
        LEFT JOIN pedidos pd ON p.id = pd.id_pessoa 
        WHERE pd.id IS NULL 
        LIMIT 1;
    """)
    res = cursor.fetchone()
    if res:
        pessoa_id, nome = res
        cursor.execute("DELETE FROM pessoas WHERE id = %s;", (pessoa_id,))
        print(f"❌ DELETE (CDC 'd'): Cliente {pessoa_id} ({nome}) foi deletado do banco!")
    else:
        print("⏳ DELETE: Nenhum cliente sem pedidos encontrado para deletar neste momento.")

if __name__ == '__main__':
    print("==========================================================")
    print("🚀 Iniciando o Gerador de Eventos CDC para a tabela PESSOAS")
    print("==========================================================")
    
    try:
        conn = psycopg2.connect(**db_config)
        cursor = conn.cursor()
        
        acoes = [insert_pessoa, update_pessoa, update_pessoa, delete_pessoa]
        
        while True:
            # Sorteia uma das ações
            acao = random.choice(acoes)
            try:
                acao(cursor)
                conn.commit()
            except Exception as e:
                conn.rollback()
                print(f"⚠️ Erro ao executar a ação: {e}")
                
            # Aguarda entre 3 e 5 segundos para a próxima ação
            time.sleep(random.randint(3, 5))
            
    except KeyboardInterrupt:
        print("\n⏹️ Gerador CDC parado pelo usuário.")
    except Exception as e:
        print(f"❌ Erro fatal de banco de dados: {e}")
    finally:
        if 'conn' in locals() and conn:
            cursor.close()
            conn.close()
