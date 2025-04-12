# 클라우드 서비스 개발자를 위한 AWS로 구현하는 CI/CD 배포 입문
신입 개발자부터 실제 서비스 구축 경험이 없는 모든 개발자를 위한 실무 밀착형 입문서

[GitHub](https://github.com/codingspecialist/Aws-Deploy-EasyupClass)

## Contents
목차
01. AWS 이해
    01-1 AWS 배포를 위한 프로젝트 환경설정
        1.1 JDK 설치
            JDK(Java Development Kit)
        1.2 환경변수 설정
            1.2.1 윈도우 shell 명령어
            1.2.2 환경변수 설정
        1.3 Visual Studio Code 설치
            1.3.1 Java Extension
            1.3.2 Spring Extension
            1.3.3 Lombok
        1.4 포스트맨 설치
        1.5 Git 설치
        1.6 프로젝트 저장 경로
    01-2 이 책의 학습 목표(AWS)
    01-3 전산실을 구축할 때 고려할 점
    01-4 AWS 탄생 배경
        4.1 제프 베이조스
    01-5 AWS 회원 가입
    01-6 EC2 서버 임대
    01-7 EC2 서버에 접속하기(Windows & Mac)
        7.1 Windows
            7.1.1 mobaxtem 설치
            7.1.2 mobaxtem 실행
        7.2 Mac
            7.2.1 aws-key 파일이 저장되어 있는 경로로 이동
            7.2.2 aws-key 파일에 실행 권한 부여
            7.2.3 EC2 접속
            7.2.4 한 줄로 EC2 접속하기
    01-8 네트워크 기본기 - 패킷의 여행
        8.1 패킷
            8.1.1 서킷 스위칭
            8.1.2 패킷 스위칭
        8.2 IP 주소
            8.2.1 IPv4
            8.2.2 IPv6
        8.3 포트 번호
    01-9 EC2 서버 방화벽
        9.1 방화벽
        9.2 Secure 가 붙은 이유
    01-10 RSA 인증방석
        10.1 대칭키 암호화 방식
        10.2 공개키 암호화 방식(RSA)
        10.3 프로토콜
            10.3.1 데이터 송신 방법
            10.3.2 데이터 수신 방법
        10.4 RSA 개념이 필요한 이유
02. 리눅스 명령어 학습
    02-1 리눅스 명령어 step 1
        1.1 clear
        1.2 pwd
        1.3 cd
        1.4 ls
        1.5 절대 경로와 상대 경로
    02-2 리눅스 명령어 step 2
        2.1 -- help
        2.2 -a, --help
        2.3 mkdir
        2.4 touch
        2.5 rm
        2.6 +C
    02-3 리눅스 명령어 step 3
        3.1 cp(copy)
        3.2 mv(move)
            3,2,1 파일 이동
            3.2.2 파일명 변경
        3.2 ln(link)
    02-4 리눅스 명령어 step 4
        4.1 Windows 에서 프로그램(카카오톡)을 설치할 때
        4.2 ubuntu repository
            4.2.1 ubuntu repsitory 등록
        4.3 PPA 저장소
    02-5 리눅스 명령어 step 5
        5.1 