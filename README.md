# Sales Analytics Project

## Layihənin məqsədi
Bu mini-proyekt satış analitikası sistemini qurmaq, SQL ilə ETL, hesabat və performans məsələlərini real halda tətbiq etməkdir.

## İstifadə olunan texnologiyalar
- SQL Server / T-SQL  
- SSMS  
- Excel (Dashboard və Pivot Chart)  
- ETL (Import Wizard)

## Daxil edilən tapşırıqlar
1. Target cədvəllər – Customers, Products, Orders  
2. Data yüklənməsi (Excel → staging → target)  
3. Hesabatlar:  
   - Top 5 Customer (sifariş sayına görə)  
   - Top 5 Product (satış məbləğinə görə)  
   - Region üzrə aylıq satış trendi (vizual üçün dashboard)  
   - Hər müştərinin son 3 sifarişi  
   - Running total və cumulative satış analiz  
4. Stored procedure – Müştərinin bütün sifarişlərini qaytarır  
5. Trigger – Yeni sifariş log cədvəlinə yazılır  
6. Index – Sorğuların performansını artırmaq üçün  
7. Excel Dashboard – Pivot Chart vasitəsilə vizual təqdimat  

## Necə işlətmək olar
1. `sales_project.sql` faylını SSMS-də işlədin — cədvəllər, prosedurlar və trigger-lər hazırlanacaq.  
2. `sales_data.xlsx` faylında həm Original Data, həm də Dashboard sekmeleri mövcuddur.  
3. Report hissəsində Excel-in Pivot Chart ilə trend qrafikləri mövcuddur.
