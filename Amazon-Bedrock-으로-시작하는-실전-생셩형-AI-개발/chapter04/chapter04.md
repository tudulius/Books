# 04. Bedrock 으로 RAG 구현하기

## 순서
* 4-1 RAG 개념
* 4-2 백터 데이터베이스
* 4-3 LangChain 으로 RAG 구현
* 4-4 관리형 서비스로 RAG 구현

## 4-1 RAG 개념
RAG(Retrieval-Augmented Generation, 검색 증강 생성) 는 LLM 의 성능을 크게 향상시키는 기술입니다. 이 방식은 LLM 이 응답을 생성하기 전에 외부의 신뢰할 수 있는 지식 저장소를 참조하여 정보를 보장하는 과정을 거침니다.

### RAG 시스템의 과정
그림 4-1 은 RAG 시스템의 정보 검색 및 응답 생성 과정을 보여주는 흐름도입니다. 이 과정은 크게 다섯 단계로 구성됩니다.

![](./jumpstart-fm-rag.jpg)

그림 4-1 AWS Developer Guide, RAG / 표 4-1 RAG 시스템의 정보 검색 및 응답 생성 과정

|   | 단계 | 상세
| :-: | :---: | :---:
| 1 | 프롬프트 + 쿼리<br>(Prompt + Query) | 사용자의 질문(Query) 이 시스템에 입력됩니다.
| 2 | 쿼리<br>(Query)                  | "
| 3 | 검색<br>(Retrival)               | 지식 소스로부터 관련 정보를 추출합니다.
| 4 | 증강<br>(Augmentaion)            | 프롬프트, 질문 그리고 검색된 정보로 강화된 컨텍스트가 LLM 에 전달됩니다.
| 5 | 생성<br>(Generation)             | LLM 이 최종 응답을 생성합니다.

출처 : https://docks.aws.amazon.com/sagemaker/lates/db/jumpstart-foundation-models-customize0rag

## RAG 의 장점
RAG 의 핵심은 두 가지 상호보완적 지식 저장사로르 결합한다는 데 있습니다. 모델이 자체적으로 보유한 파라미터 기반 지식과 외부 저장소에서 검색된 비파리미터 지식을 통합하여 더욱 정확하고 맥락에 맞는 응답을 생성합니다. 이는 마치 오픈북 시험에서 암기한 내용과 참고 자료를 동시에 활용하는 것과 유사한 방식으로 LLM 의 활용 범위를 크게 확장시킵니다.

외부 저장소의 정보를 사용한다는 점에서 RAG 는 다음과 같은 장점이 있습니다.

➊ 유연성 및 비용 효율성: 전체 모델을 재학습할 필요 없이 검색 문서 교체만으로 지식 업데이트를 할 수 있습니다. 이는 시간과 비용을 절감하고 지속적인 성능 개선을 가능하게 합니다.
➋ 특정 도메인 지식 통합에 따른 정확성과 신뢰성 향상: 전문 지식을 효과적으로 통합하고 신뢰할 수 있는 최신 정보를 활용하여 더 정확하고 관련성 높은 응답을 생성합니다.

다음으로 RAG 개념에서 대량의 문서나 데이터를 벡터화하여 저장하고 사용자 쿼리와 가장 관련성 높은 정보를 검색 가능하게 하는 벡터 데이터베이스에 대하여 알아보겠습니다.

## 4-2 벡터 데이터베이스
벡터 데이터베이스는 텍스트, 이미지, 오디오 등 다양한 유형의 데이터를 고차원의 벡터로 변환하여 효울적으로 저장, 검색 및 처리하기 위한 데이터베이스 시스템입니다. 이 과정에서 임베딩 모델이 핵심적인 역활을 수행합니다. 데이터가 벡터로 인코딩되면 이를 벡터 데이터베이스에 인덱싱하여 유사한 벡터를 쿼리할 수 있습니다. 이를 통해 유사한 데이터를 효과적으로 찾아낼 수 있습니다. 이때 벡터 데이터베이스는 N 차원의 공간에서 가까운 데이터를 조회할 수 있는 k-NN(k-Nearest Neighbor, k-최근점 이웃) 검색 기법을 활용하여 벡터 간의 거리를 계산하고 유사도를 판단합니다.

이러한 벡터 데이터베이스의 특성은 RAG 시스템의 Retrieval 단계에서 중요한 역활을 합니다. RAG 시스템에서 Retrieval 은 사용자의 질문이나 입력에 관련된 가장 적절한 정보를 대규모 지식 베이스에서 빠르고 정확하게 찾아내는 과정입니다. 벡터 데이터베이스를 사용하면 사용자의 질문을 벡터로 변환한 후 이와 가능 유사한 벡터들을 효울적으로 검색할 수 있습니다. 이렇게 검색된 정보는 LLM 에 제공되어 더욱 정확하고 관련성 높은 응답을 생성하는 데 활용됩니다.

생성형 AI의 등장 이전에는 Faiss 와 같은 라이브러리가 고차원 벡터 데이터 검색에 주로 사용되었습니다. 그러나 LLM 과 같은 생성형 AI 모델의 출현으로 벡터 데이터베이스에 대한 수요가 급증했습니다. 이에 따라 Pinecone, Milvus, 등 벡터 데이터에 특화된 전용 데이터베이스가 등장하게 되었습니다. AWS 를 비롯한 주요 클라우드 서비스 제공 업체들도 기존 데이터베이스 서비스에 벡터 데이터 저장 및 검색 기능을 추가로 제공하기 시작했습니다. 이러한 벡터 데이터베이스 발전은 RAG 시스템의 Retrieval 성능을 크게 향상시켜 더 정확하고 관련성 높은 정보를 신속하게 제공할 수 있습니다.

### AWS 에서 제공하는 벡터 데이터베이스
AWS 는 임베딩 벡터들을 저장하고 효율적인 유사성 검색을 수행 할 수 있는 다양한 벡터 데이터베이스 솔루션과 다양한 사용 사례에 맞춰 여러 벡터 데이터베이스 옵션을 제공하고 있습니다. 그중에는 그래프 데이터를 지원하는 'Amazon Neptune ML:', 모든 데이터를 모머리에 저장하여 빠른 벡터 검색을 가능하게 하는 'Amazon MemoryDB' 그리고 'MongoDB' 와 호환되는 'Amazon DocuemtnDB' 등이 있습니다. 이 중에서 가장 널리 사용되는 두 가지 옵션인 'Amazon OpenSearch Service' 와 'Amazon Aurora PostgreSQL' 의 'pgvector' 에 대해 좀 더 자세히 살펴보겠습니다.

### 1. Amazon OpenSearch Service
Amazon OpenSearch Service 는 AWS 에서 제공하는 완전 관리형 OpenSearch 서비스로 RAG 및 생성형 AI 애플리케이션을 위한 강력한 벡터 데이터베이스 솔루션을 제공합니다. 이 서비스의 주요 특징은 다음과 같습니다.

❶ 효율적인 벡터 검색
- k-최근접 이웃(k-NN) 알고리즘을 사용하여 고차원 벡터 공간에서 의미적으로 유사한 데이터를 빠르게 검색합니다.
- HNSW(Hierachical Navigable Small WOrkd) 알고리즘을 통해 대규모 데이터 세트에서도 효울적인 검색을 가능하게 합니다.

❷ 다양한 유사도 측정 지원
- 유클리드 거리, 코사인 유사도, 내적 등 다양한 거리 측정 방식을 제공하여 다양한 사용 사례에 적응 가능합니다.

❸ 하이브리드 검색 기능
- 전통적인 키워드 기반 검색과 의미 기반 벡터 검색을 결합하여 더욱 정확하고 관련성 높은 정보를 검색할 수 있습니다.
- MB25 와 같은 전통적인 검색 알고리즘과 벡터 검색 점수를 조합하여 검색 결과의 품질을 향상시킬수 있습니다.

❹ 서버리스 옵션
- Amazon OpenSearch Serverless 를 통해 인프라 관리 없이 벡터 검색 기능을 사용할 수 있습니다.
- 트래픽 변동에 따라 OpenSearch 컴퓨팅 유닉(OCU) 이 자동으로 확장되어 성능을 유지하여 운영 부담을 크게 줄일 수 있습니다.
- 사용량에 따른 비용 지불로 비용 효울성을 높일 수 있습니다.

❺ 확장성
- 수십억 개의 벡터를 처리할 수 있어 대규모 지식 베이스를 필요로 하는 엔터프라이즈급 RAG 시스템 구축에 적합합니다.
- 16,000차원까지의 벡터를 지원하여 복잡한 임베딩 모델의 결과를 저장하고 검색할 수 있습니다.

Amazon OpenSearch Service 를 활용한 RAG 시스템은 생성형 AI 모델의 지식을 확장하고 최신 정보로 모델의 출력을 보강하며 특정 도메인에 특화된 정보를 제공할 수 있습니다. AWS 의 관리형 서비스로서 인프라 관리 부담을 줄이고 높은 가용성과 안정성을 제공하며 엔터프라이즈 수준의 보안을 갖춘 RAG 솔루션을 구축할 수 있습니다. 특히 서버리스 옵션을 통해 더욱 유연하고 비용 효울적인 RAG 시스템을 운영할 수 있도록 지원합니다.

### 2. Amazon Aurora PostgreSQL 및 RDS for PostgreSQL 에서의 pgvector
오픈소스 PostgreSQL 커뮤니티에서 새로운 데이터 유형과 인덱싱 방법을 베공하기 위해 벡터 유사도 검색을 지원하는 pgvector 확장 기능을 제공합니다.

AWS 에서도 PostgreSQL 을 지원하는 방식인 Amazon RDS for PostreSQL 과 Amazon Aurora PostgreSQL 에 pgvector 확장을 지원하여 벡터 데이터베이스 솔루션을 제공하기 시작했습니다. 이 확장 기능의 주요 특징은 다음과 같습니다.

❶ 고성능 벡터 연산 지원
- IVFFlat, HNSW 와 같은 근사 최근점 이웃(ANN) 인덱스를 활용하여 벡터 유사성 검색을 효율적으로 수행합니다.
- Jaccard, Hamming distance 와 같은 비트별 거리 함수를 통해 이진 양자화를 효울적으로 지원합니다.

❷ PostgreSQL 통합
- 기존 PostgreSQL 데이터베이스에 쉽게 통합되어 관계형 데이터와 벡터 데이터를 함께 저장하고 쿼리할 수 있습니다.
- SQL 인터페이스를 통해 벡터 연산을 수행할 ㅅ ㅜ있어 기존 PostgreSQL 사용자에게 친숙합니다.

❸ 하이브리드 검색 기능
- 전통적인 SQL 쿼리와 벡터 검색을 결합하여 복잡한 검색 조건을 구현할 수 있습니다.
- 메타데이터 필터링과 벡터 유사성 검색을 동시에 수행할 수 있어 정확하고 관련성 높은 결과를 얻을 수 있습니다.

❹ 서버리스 옵션
- 완전 관리형 서비스인 Amazon Aurora Serverless 를 통해 인프라 관리 부담을 줄일 수 있습니다.
- 트래픽 변동에 따라 Aurora 용량 단위(ACU) 가 자동으로 확장되어 성능을 유지하여 운영 부담을 크게 줄일 수 있습니다.
- 사용량에 따른 비용 지불로 비용 효울성을 높일수 있습니다.

❺ 활발한 커뮤니티와 지속적인 개발
- 오픈소스 프로젝트로서 활발한 커뮤니티 지원과 지속적인 기능 개선이 이루어지고 있습니다.
- 23개 이상의 pgvector client 를 통해 다양한 언어(Go. Python, Rust 등 언어를 포함) 을 지원합니다.

pgvector 를 활용한 RAG 시스템은 PostgreSQL 의 강력한 기능과 벡터 검색 능력을 결합하여 효과적인 지식 검색 및 정보 검색 솔루션을 제공합니다. 기존 PostgreSQL 의 인프라를 활용할 수 있어 도입 비용을 낮출 수 있으며 SQL 의 유연성을 통해 복잡한 쿼리와 데이터 처리가 가능합니다. 이는 특히 PostgreSQL 을 이미 사용 중인 조직에서 RAG 시스템 구축 시 매력적인 선택이 될 수 있습니다.

## 4-3 LangChain 으로 RAG 구현
RAG 과정에서 검색(Retrieval) 기능을 구현하기 위해서는 여러 단게의 작업이 필요합니다. 이는 참조할 텍스트 추출, 문서 분할 그리고 임베딩 검색을 포함합니다. 관리형 서비스를 사용하지 않는 경우 검색 준비 작업부터 최종 검색까지 전체 파이프라인을 직접 구현해야 합니다. 이러한 맥락에서 곤리형 서비스를 활용한 RAG 구현을 살펴보기 전에 먼저 pgvector 를 사용하여 RAG 를 직접 구현하는 방법에 대해 알아보겠습니다. 이를 통해 RAG 기본 원리와 구현 과정을 더 깊이 이해할 수 있을 겁니다. 기본적인 RAG 구현의 첫 단계로 AWS 관리 콘솔에서 RDS 에 접속하여 pgvector 확장 기능을 지원하는 PostgreSQL 로 벡터 데이터베이스를 구성하겠습니다.

01. AWS RDS 관리 콘솔에 접속한 후 [데이터베이스 생성] 버튼을 클릭합니다.

02. 편의상 [데이터베시이스 생성 방식] 은 [표준 생성] 으로 [에진 옵션] 은 [Aurora (PostgreSQL Compatible)] 로 선택합니다. 나머지 설정은 기본값을 유지하고 [템플릿] 은 [개발/테스트] 로 지정합니다. (그림 4-3 에는 실습과 관련 없는 일부 엔진 유형을 제외하였습니다.)

03. [DB 클러스터 식별자] 를 [pgvector] 로 [마스터 사용자 이름] 을 'postgres' 로 입력해 설정합니다. 또 [자격 증명 관리] 부분을 [자체 관리]로 선택하고 [마스터 암호] 를 편의에 맞춰 임의로 설정ㅏㅂ니다. 다만 마스터 암호는 최소제약 조건에 맞춰 설정해야 합니다.

> 그림 4-4. RDS 데이터베이스 생성 - 이름 및 자격 증명 설정

04. 클러스터 스토리지 구성은 기본값을 선택합니다. [인스턴스 구성]은 [서버리스 v2]로 클래스를 정하고 용량 범위에서 최소/최대 ACU 를 각각 '1', '4' ACU 로 설정하겠습니다. 이 구성은 필요에 따라 서버리스가 아닌 On-Demand 형태의 인스턴스로도 대체 가능합니다.

> 그림 4-5. RDS 데이터베이스 생성 - 인스턴스 구성

05. [퍼블릭 액세스]는 [예]로 [VPC 보안 그룹(방화벽)]은 [새로 생성]을 선택하고 [새 VPC 보안 그룹 이름]은 'pgvector-sg'라고 설정하겠습니다. 이떄 새로 설정한 'pgvector-sg'보안 그룹에는 자동으로 PostgreSQL 의 기본 포트인 5432 에 대한 인바운드 규칙이 생성되어 사용자의 IP에서 접근 가능이 가능하도록 설정됩니다. 나머지 모든 설정은 기본값을 유지합니다.

06. 수분 후에 RDS 생성이 완료되면 '리전 클러스터'와 '라이터 인스턴스'가 사용 가능한 상태로 표시됩니다. 생성한 pgvector에 접근하기 위해 리전 클러스터 라이터 엔드포인트를 복사해 둡니다.

> 4-7 생성 완료된 RDS의 엔드 포인트 복사

이번 실습에서 사용할 Amazon Titan Text Emveddings V2와 Claude 3.5 Sonnet 모델에 대한 권한 설정이 완료되었다면, RAG 를 테스트하기 위한 인프라가 모두 준비된 것입니다. 먼저 RAG 를 사용하지 않은 상태에서 Claude 3.5 Sonnet 모델이게 코드 4-1 을 실행시켜 'Titan Text Embeddings V2' 의 차원 수를 질문해 보겠습니다.
```
from langchain_aws import ChatBedrockConverse

llm = ChatBedrockConverse(model="anthropic.claude-3-5-sonnet-20240620-v1:0")
response = llm.invoke("Titan Embedding V2는 몇 차원인가요?")

print(response.content)
```
```
답변 1 : Titan Embedding V2의 정확한 차원에 대해서는 공개된 정보가 없어 확실하게 말씀드리기 어렵습니다. 일반적으로 대규모 언어 모델의 임베딩 차원은 수백에서 수천 차원 정도인 경우가 많지만 Titan Embedding V2 의 구체적인 차원은 공식적으로 발표죄디 않았습니다. 정확한 정보를 원하신다면 개발사에 직업 문의해보시는 것이 좋을 것 같습니다. 

답변 2 : Titan Embedding V2 는  3072 차원입니다.
```

RAG 없이 모델에게 질문하면 Amazon Titan Text Embeddings V2 에 대한 질문에 대해 답변 1 과 같이 정확한 정보를 제공하지 못하거나 답변 2와 같이 잘못된 정보(Hallucination, 할루시네이션, 환각 현상) 을 생성할 수 있습니다.

이제 Amazon Titan 모델들에 대한 정보를 활용하여 정확한 답변을 제공할 수 있는 RAG 시스템을 구축해 보겠습니다. 관리형 서비스를 사용하지 않을 경우 RAG 의 모든 구성 요소를 직접 코드로 구현해야 합니다. RAG 의 워크플로우를 이해하고 있다면 각 구성요소에 해당하는 LangChain 모듈을 활용하여 직접 구현할 수 있습니다. 먼저 가상환경에서 다음 명령어를 사용하여 필요한 패키지들을 설치하겠습니다.
```
pipenv install langchain-aws langchain langchain-community bs4
```

먼저 답변을 생성하기 위한 Chat 모델과 유사도 검색을 위한 임베딩 모델을 준비합니다. 아래는 모델 호출에 필요한 최소한의 코드이므로, 상황에 맞게 추론 매개변수와 리전 정보 등을 조정해야 합니다.

```
llm = ChatBedrockConverse(model="anthropic.claude-3-5-sonnet-20240620-v1:0")
embedding = BedrockEmbeddings(model_id="amazon-titan-embed-text-v2:0")
```

다음으로 모델이 참조할 수 있는 정보를 제공하는 코드를 작성하겠습니다. 웹에서 참고할 문서를 벡터 데이터베이스에 저장하기 위해 문서를 불러오는 loader와 이를 적절한 크기로 분할하는 spitter 를 구현합니다. 이 과정을 통해 문서를 모델이 효과적으로 활용할 수 있는 형태로 가공합니다. 문서의 특성에 따라 chunk_size 와 chunk_overlap 등의 파라미터 값을 최적화할 수 있습니다. 본 실습에서는 RAG 의 기본 흐름을 이해하는 데 중점을 두어 이러한 파리미터들을 임의의 값으로 설정하였습니다.

```
loader = WebBaseLoader("https://aws.amazon.com/bedrock/titan/")
docs = loader.load()

text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)
splits = text_splitter.split_documents(docs)
```

문서 준비가 완료되면 벡터 데이터베이스를 구성합니다. 이를 위해 PostgreSQL, 접속 정보를 설정합니다. USER는 'postgresql'로 PASSWORD 는 그림 4-4 에서 설정한 'pgvector' 를 DATABASE 이름은 'postgres' 를 사용합니다. 또한 그림 4-7 에서 복사한 엔드포인트를 ENDPOINT 값으로 입력합니다. 이 후 'PGVecter' 클래스에 준비된 문서와 임베딩 모델 그리고 위에서 설정한 접속 정보를 전달하여 벡터 데이터베이스 사용 준비를 완료합니다.

```
connection ="postgresql+psycopg://{USER}:{PASSWORD}@{ENDPOINT}:5432/{DATABASE}"
collection_name = "aws_vector"

vectordb = PGVector.from_documents(
    documents=splits,
    embedding=embeddings,
    connection_string=connection,
    collection_name=collection_name,
    use_jsonb-Truem
)
```

제공된 문서를 기반으로 답변을 받기 위해 질문을 포함하고 관련 문맥을 제공하는 프롬프트를 작성합니다. 언어 모델이 주어진 문맥과 질문을 명확히 구분할 수 있도록 xml 태그로 문맥을 감싸고 'Question:' 키워드를 사용하여 질문을 표시했습니다. 이러한 구조화된 프롬프트는 모델의 이해와 응답 정확도를 향싱시킵니다.

```
prompt_template = """
    마지막에 질문에 대한 간결한 답변을 제공하기 위해 다음 문맥을 활용하세요.
    답을 모른다면 답을 지어내려고 하지 말고 모른다고 말하세요.
    
    <context>
    {context}
    </context>

    Question: {question}
"""

prompt = PromptTemplate(
    template=prompt_template, input_variables=["context", "question"]
)
```

마지막으로 검색된 문서들을 하나의 문자열로 결합하는 'format_docs' 함수를 작성하고 RAG 시스템을 구현하기 위한 체인을 설정합니다.

```
def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)

rag_chain = (
    {
        "context": vectordb.as_retriever() | format_docs,
        "question": RunnablePassthrough(),
    }
    | prompt
    | llm
    | StrOutputParser()
)
```

모든 과정을 하나의 파이프라인 형태로 묶는 RAG Chain 은 LCEL(LangChain Expresion Language) 문법으로 작성되었으며 다음과 같은 과정을 거침니다.

❶ 벡터 DB에서 관련 문서를 검색하고(vectordb.as_retriever()), 이름 format_docs 함수를 통해 포맷팅합니다.

❷ 사용자의 질문을 그대로 전달합니다.(RunnablePassthrough())

❸ 검색된 문서와 질문을 미리 정의된 프롬프트 템플릿에 적용합니다.

❹ 생성된 프롬프트를 언어 모델에 입력하여 응답을 생성합니다.

❺ 마지막으로 생성된 응답을 문자열로 파싱합니다.

> * TIP
> * LangChain 에서 Vector Store 와 Retriever 는 어떻게 다른가요?

> LangChain 의 주요 구성 요소 중 유사도 검색을 지원하는 방법으로 Vector Store 와 Retriever 두 가지가 있습니다. AWS 서비스로 RAG 를 구현할 떄 MemoryDB 와 pgvector 는 Vector Store 모듈을 사용하고 Amazon Kendra 와 Amazon KnowledgeBase 는 Revriever 모듈을 사용합니다. 

> 이 두 모듈은 모두 자체적인 유사도 검색을 지원하기 때문에 혼동하기 쉽습니다. Vector Store 는 벡터 데이터를 저장하고 관맇사는 DB 기능과 유사성 검색을 위한 인덱싱 기능을 제공합니다. 반면 Retriever 는  Vector Store 으 ㅣ개념을 포함하는 더 넓은 범위의 검색 인터페이스입니다. 이는 쿼리에 대한 정보를 검색하는 기능 뿐만아니라 쿼리 처리 로직과 결과에 대한 필터링 등 추가적인 기능을 제공합니다.

> 즉 Vector Store 는 벡터 데이터를 저장하고 검색하는 기본 인프라를 제공하고 Retriever 는 이를 활용하여 더 복잡한 검색 로직을 구현한 상위 컴포넌트라고 할 수 있습니다.

지금까지 유리는 RAG 의 핵심 구성 요소(loader, splitter, chat/embedding, model, vector db) 를 직접 구형하고 LCEL 문법을 사용하여 이를 파이프라인으로 구축하는 방법을 학습했습니다. 비록 실제 업무 환경에서 LangChain 을 활용한 RAG 파이프라인 구축이 필요하지 않을 수도 있지만 이렇게 RAG 의 기본 구성 요소들을 이해하고 있다면 관리형 서비스를 사용할 때3도 더욱 효과적을 활용할 수 있을 것입니다.

```
from langchain_aws import ChatBedrockConverse
from langchain_aws import BedrockEmbeddings
from langchain.prompts import PromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough
from langchain_community.document_loaders import WebBaseLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_community.vectorstores import PGVector

llm = ChatBedrockConverse(model="anthropic.claude-3-5-sonnet-20240620-v1:0")
embeddings = BedrockEmbeddings(model_id="amazon.titan-embed-text-v2:0")

loader = WebBaseLoader("https://aws.amazon.com/bedrock/titan/")
docs = loader.load()

text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)
splits = text_splitter.split_documents(docs)

connection = "postgresql+psycopg://postgres:pgvector@pgvector2.cluster-example12345.ap-northeast-2.rds.amazonaws.com:5432/postgres"
collection_name = "aws_vector"

vectordb = PGVector.from_documents(
    documents=splits,
    embedding=embeddings,
    connection_string=connection,
    collection_name=collection_name,
    use_jsonb=True,
)

prompt_template = """
    마지막에 질문에 대한 간결한 답변을 제공하기 위해 다음 문맥을 활용하세요.
    답을 모른다면 답을 지어내려고 하지 말고 모른다고 말하세요.
    
    <context>
    {context}
    </context>

    Question: {question}
"""

prompt = PromptTemplate(
    template=prompt_template, input_variables=["context", "question"]
)

def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)

rag_chain = (
    {
        "context": vectordb.as_retriever() | format_docs,
        "question": RunnablePassthrough(),
    }
    | prompt
    | llm
    | StrOutputParser()
)

answer=rag_chain.invoke("Titan Embedding V2는 몇 차원인가요?")
print(answer)
```

코드 4-2. AWS 서비스들과 LangChain 으로 구헝한 RAG

> Titan Text Embeddings V2 는 세가지 지원 옵션을 제공합니다. 256, 512, 1024 지원입니다.

코드 4-2 를 실행하면 그럼 4-8에 웹페이지에 언급된 임베딩 개수를 참조하여 RAG 시스템이 주어진 질문에 대해 관련 문서를 효과적으로 검색하고 그 정보를 바탕으로 다음과 같이 정확하고 답변을 생성했음을 확인할 수 있습니다.

* TIP
* LangCHain 으로 작성된 코드에서 pgvector 의 임베딩 차원을 변경하고 싶습니다.
1536 차원의 임베딩을 생성하는 Amazon Titan Text Embeddings 에서 1024 차원의 Amazon Titan Text Embeddings V2 로 임베딩 모델을 변경하려 하면 다음과 같은 오류 메세지가 발생합니다.

> psycopg.erros.DataException: different vector demensions 1024 and 153

이는 두 임베딩 모델이 생성하는 벡터의 차원이 다르기 때문에 발생하는 문제입니다. 따라서 차원이 다른 임베딩 모델로 변경하려면 벡터 데이터베이스에 저장된 정보를 교체해야 합니다. 이 문제를 해결하는 과정은 다음과 같습니다.

1. 터메널에서 다음 명령어로 벡터 DB에 접속합니다.
```
psql --host={Endpoint} --port={port} --username={Database}
```

2. LangChain 이 생성한 테이블을 조회합니다.
```
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';
```

3. 조회된 테이블(langchain_pg_collection, langchain_pg_embeddin)들을 삭제합니다.
```
DROP TABLE langchain_pg_embedding CASCADE;
```

## 4-4 관리형 서비스로 RAG 구현: Knowledge Bases for Amazon Bedrock

LLM이 질문에 사실과 다른 답변을 하는 것을 환각 현상이라고 하는 데 이것을 줄이기 위해 RAG 기법이 도입되었습니다. 이 기법을 통해 미세조정 없이도 LLM 의 제한적인 정보 활용 문제를 개선하여 보다 정확한 응답을 생성할 수 있게 되었습니다. 그런 RAG 를 구현하기 위해 문서 수집 과정, 텍스트 분할, 임베딩, 벡터 데이터베이스 구축 등 일련의 과정을 일일이 개발해야 하는 번거로움이 수반됩니다. AWS 는 이러한 복잡한 RAG 과정을 간소화하고 추상화한 서비스인 'Knowledge Bases for Amazon Bedrock(이하 Bedrock 지식 기반)' 을 're:Invent 2023' 에서 정식으로 출시하였습니다. 이번 섹션에서는 Bedrock 지식 기반의 각 옵션에 따른 차이와 구성 방법에 대해 소개하겠습니다.

### Bedrock 지식 기반의 벡터 데이터베이스
현재 Bedrock 지식 기반은 벡터 데이터베이스로 그림 4-9 와 같이 5가지 옵션을 제공하고 있습니다. AWS 기반 RAG 를 구축하려면 'Amazon OpenSearch Serverless' 혹은 'Amazon Aurora' 를 사용하게 됩니다. 'Pinecone', 'MongoDB Atlas' 와 'Redis Enterprise Cloud' 는 AWS 의 네티티브 서비스가 아니며 추가적인 관리가 필요하므로 이 책에서는 다루지 않겠습니다.

Amazon Aurora 는 OpenSearch 와 달리 On-demand 방식과 Serverless 방식을 모두 지원합니다. 완전 관리형 형태로 지식 기반의 벡터 데이터베이스를 구축하고자 한다면 'Aurora Serverless' 를 권장합니다. Aurora Serverless 는 애플리케이션 상황에 따라 자동으로 확장/축소되어 관리 부담을 크게 줄일 수 있는 이점이 있습니다.

새로 구축하는 경우에는 'Amazon OpenSearch Serverless 가 가장 편리한 옵션입니다. 추가 정보 입력 없이 Bedrock 지식 기반을 생성할 수 있는 OpenSearch Serverless 옵션에 대해 먼저 살펴보겠습니다. 

### OpenSearch Serverless 를 통해 Bedrock 지식 기반 생성하기
Bedroc 지식 기반 콘솔에 접속하여 지식 기반 생성을 시작합니다. Bedrock 지식 기반은 기본적을 S3 를 데이터 소스로 사용하므로 사전에 'S3 버킷' 을 생성하고 입베딩하고자 하는 파일을 업로드해야합니다. S3 외에도 미리보기(Preview) 기능으로 다음과 같은 추가 데이터 커넥터를 지원합니다.

➀ 웹 크롤러: 공개된 ㄷ메인의 웹 페이지로부터 텍스트 등의 컨텐츠를 추출

➁ Confluence: 문서 기반 협업을 할 떄 사용되는 아틀라시안이 개발한 위키 서비스

➂ Salesforce: 영업 및 마케팅 데이터를 위한 고객 관계 관리(CRM) 솔루션

➃ Sharepoint: 마이크로소프트(Microsofr)에서 개발한 웹 기반 협업 플랫폼

이 예시에서는 OpenSearch Serverless 를 통해 Bedrock 지식 기반을 생성할 때 S3 를 데이터 소스로 지정하겠습니다. Bedrock 지식 기반에 대해 대한 이해를 돕기 위해, 가장 기본적인 구성으로 RAG를 구축하는 방법을 설명하겠습니다.

01. 그림 4-10 과 같이 S3 버킷에 RAG에서 참조할 문서를 업로드합니다. 이 예시에서는 '중대재해처벌법' 에 관한 PDF 를 업로드했습니다.

02. Bedrock 지식 기반 생성 화면에 진입하면 그림 4-11 과 같이 식별 가능한 지식 ㅣ기반의 이름을 지정합니다. 그 다음 다른 서비스에 대한 권한을 사용하기 위한 IAM 역활을 설정합니다. [Amazon S3] 를 지정한 후 다음 단계로 진행합니다.
    1. Bedrock 내 임베딩 모델 등의 모델 호출 권한
    2. 벡터 데이터베이스에 대한 API 접근 권한
    3. S3 버킷 및 객체에 대한 접근 권한

03. 데이터 소스 설정 단계입니다. [S3 찾아보기] 버튼을 클릭하면 원하는 S3 버킷을 선택할 수 있습니다. 단 Bedrock 지식 기반과 동일한 리전에 위치한 S3 버킷만 선택 가능합니다. 선택 시 버킷 전체를 지정하거나 특정 접두사(폴더명 기준)을 기준으로 선택할 수 있으며 필요한 경우 개벌 파일만을 선택하여 업로드할 수도 있습니다. 그럼 4-12 하단의 [다른 데이터 소스 추가] 버튼을 통해 최대 5개의 데이터 소스를 지정할 수 있습니다. 청킹 및 파싱 구성을 기본값인 [Default] 로 설정합니다.

청킹 전락(Chunking strategy) 설정
> Bedrock 지식 기반을 생성할 떄 청킹 및 파싱 구성(Chucking and pasing configuraiton) 에서 청크(Chuck) 를 어떻게 나눌지 결정하는 청킹 전략(Chucking stragegy) 을 설정할 수 있습니다. 기본값(Default) 으로 설정하면 소스 데이터를 최대 300개의 토큰을 포함하는 청크로 자동 분할하는 기본 청킹 방식이 적용됩니다.

04. 이어서 고급 설정에 대해서 알아보겠습니다. 그림 4-13의 [고급 설정]에서 '데이터 삭제 정책'을 설정할 수 있습니다. [Default(삭제)]로 설정하면 Bedrock 지식 기반 및 데이터 소스(S3) 가 삭제될 때 벡터 데이터베이스의 데이터도 함께 삭제됩니다. 반면 [Retain(유지)] 을 설정하면 Bedrock 지식 기반이나 데이터 소스가 삭제되어도 벡터 데이터베이스의 데이터는 유지됩니다.

데이터를 최신 상태로 유지하기 위해 벡터 데이터베이스 내 임베딩으로 변환된 데이터를 주기적으로 삭제해야 하는 경우가 있습니다. 삭제 작업을 직접 쿼리로 수행하는것인 비효울적이므로 일반적으로 "Delete" 정책 설정을 권장합니다. 이 방식을 통해 데이터 관리를 보다 더 효율적으로 할 수 있습니다.

05. 데이터 소스 설정을 마치면 그림 4-14 와 같이 임베딩 모델과 벡터 저장소를 구성하는 단계로 넘어갑니다. 여기서는 널리 사용되는 [Titan Text Embeddings v2] 모델을 선택하여 데이터를 임베딩으로 변환하겠습니다. 이 모델은 벡터 차원 크기(vector dimmensionality) 를 의미하는 '벡터 차수'를 256, 512, 1024 중에서 선택할 수 있습니다.

임베딩 유형 설정도 가능합니다. 기본값인 [Floating-point vector embeddings] 를 선택하면 float32 자료형으로 임베딩이 저장됩니다. 이는 가장 정확하지만 차원당 4바이트의 크기를 차지합니다. 반면 [Binary vector embeddings(이진 벡터 임베딩)] 는 32비트 임베딩 값을 1비트로 변환합니다. 이 방식은 80~90% 의 검색 정확도를 유지하면서도 메모리와 스토리지 사용량이 32배 줄여 저장 비용을 크게 절감하고 검색 속도도 향상시킬수 있습니다. 이 설정에서는 최대 성능을 위해 기본값을 선택합니다.

벡터 차원 크기는 성능과 속도 간의 균형을 조절합니다. 크기가 클수록 더 세밀한 차이를 표현할 수 있지만 계산량이 증가하여 연상 속도가 느려집니다. 반면 크기가 작을수록 정확도는 다소 감소하지만 더 빠른 응답을 생성할 수 있습니다. 이 설정에서는 기본값인 [1024] 를 선택하겠습니다.

06. 그림 4-15 는 벡터 데이터베이스 구성을 정리한 그림입니다. [새로운 벡터 저장소 빠른 생성] 옵션을 선택하면 Bedrock 이 자동으로 OpenSearch Serverless 벡터 저장소를 생성하고 데이터 소스를 임베딩한 후 쿼리 가능한 형태로 변환합니다.

이 원클릭 방식은 편리하지만 다음 사항들을 주의해야 합니다.

> 1. 이중화 활성화: 프로덕션 환경에서 높은 가용성을 보장하기 위해 Multi-AZ 구성이 필요합니다. 활성화 시 OpenSearch 컴퓨팅 유닛(OCU) 4개에 대해 월 $702.72 가 부과되며 비활성화 시에는 그 절반인 $351.36 가 부과됩니다.

> 2. Bedrock 지식 기반 삭제 시 주의사항: Bedrock 지식 기반을 삭제해도 Bedrock 이 생성한 OpenSearch Serverless 는 자동으로 삭제되지 않습니다. 불필요한 과금을 방지하기 위해 수동으로 삭제를 통해 관리해야 합니다.

07. 벡터 데이터베이스를 선택하고 [다음] 버튼을 클릭하면 그림 4-16 과 같이 [검토 및 생성] 단계로 이동합니다. 이 단계에서 는 지금까지 설정한 모든 옵션들이 적절히 구성되었는 지 확인할 수 있습니다. 모든 설정이 적절하다면 [지식 기반 생성] 버튼을 클릭하여 Bedrock 지식 기반 생성을 완료합니다.

08. 지식 기반 생성이 완료되면 그림 4-17 과 같이 생성된 Bedrock 지식 기반읜 콘솔 화면에 접속할 수 있습니다. 여기서 데이터 소스를 처음으로 동기화하는 과정이 필요합니다. 동기화할 데이터 소스를 선택하고 [동기화] 버든을 클릭합니다. 이후에도 데이터 소스가 변경될 때마다 이 동기화 작업을 수행할 수 있습니다.

Bedrock 지식 기반 콘솔에서는 그림 4-18 과 같이 간단한 테스트가 가능합니다. 이 테스트를 통해 기존에 입력한 소스 문서에서 관련 정보를 찾아 최종 답변을 생성하는 과정을 확인할 수 있습니다.

또한 [소스 세부 정보 표시] 버튼을 클릭하면 그림 4-19 와 같이 쿼리와 관련된 데이터 소스의 청크 정보를 자세히 볼 수 있습니다. 이 기능은 LLM 이 생성한 답변의 신뢰성을 검증하고 보완하는 데 유용합니다.

### Aurora Serverless v2 를 통해 Bedrock 지식 기반 생성하기
OpenSearch Serverless 를 통해 가장 쉽고 빠르게 Bedrock 지식 기반을생성하는 방법에 대해 알아보았습니다. 새로운 벡터 데이터베이스를 구축하는 것 외에도 기존에 보유한 벡터 데이터베이스를 연동할 수 있습니다. 이 경우에도 OpenSearch Serverless 를 사용할 수 있지만 비용을 저렴하게 사용하길 원한다면 Amazon Aurora Serverless v2 를 사용해 볼 것을 권장합니다.

OpenSearch Serverless 의 경우 복제본을 비활성화하면 최소 OCU 가 2개가 되어 버지니아 리전 기준 시간당 $0.24 로 한 달에 $0.24, 2*24*30.5=$351.36 가 부과됩니다. 반면 Aurora Serverless v2 는 최소 0.5 ACU 로 시작하여 버지니아 리전 기준 ACU/시간당 $0.12 월 $43.92 로 OperSearch Serverless 옵션에 비해 8배 저렴합니다.

경제적으로 Bedrock 지식 기반을 사용할 수 있