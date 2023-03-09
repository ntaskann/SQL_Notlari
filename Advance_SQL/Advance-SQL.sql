CREATE TABLE film 
(
id int ,
title VARCHAR(50),
type VARCHAR(50),
length int 
);
    
INSERT INTO film VALUES (1, 'Kuzuların Sessizliği', 'Korku',130);
INSERT INTO film VALUES (2, 'Esaretin Bedeli', 'Macera', 125);
INSERT INTO film VALUES (3, 'Kısa Film', 'Macera',40);
INSERT INTO film VALUES (4, 'Shrek', 'Animasyon',85);
CREATE TABLE actor 
(
id int ,
isim VARCHAR(50),
soyisim VARCHAR(50)
);
    
INSERT INTO actor VALUES (1, 'Christian', 'Bale');
INSERT INTO actor VALUES (2, 'Kevin', 'Spacey');
INSERT INTO actor VALUES (3, 'Edward', 'Norton');

do $$

declare
    film_count integer :=0;
begin
    select count(*) -- kaç tane film varsa sayısını getirir
    into film_count -- Query den gelen neticeyi film_count isimli değişkene atar
    from film; -- tabloyu seçiyorum
    
    raise notice 'The number of films is %', film_count; -- % işareti yer tutucu olarak kullanılıyor
	
end  $$ ;

--***************************************************************
--********************* VARIABLES - CONSTANT ********************
--***************************************************************

do $$

declare 
 	counter    integer	   :=1;
 	first_name varchar(50) :='John';
	last_name  varchar(50) :='Doe';
	payment    numeric(4,2):=20.5;

begin
	raise notice '% % % has been paid % USD',
				counter,
				first_name,
				last_name,
				payment;


end $$;

-- Task 1 : değişkenler oluşturarak ekrana " Ahmet ve Mehmet beyler 120 tl ye bilet aldılar. "" cümlesini ekrana basınız

do $$

declare

	first_person  varchar(50):='Ahmet';
	second_person varchar(50):='Mehmet';
	payment       numeric(3) :=120;
	

begin
	raise notice '% ve % beyler % tl ye bilet aldilar',
				first_person,
				second_person,
				payment;

end $$;

--********************* BEKLETME KOMUDU **************************

do $$

declare
	created_at	time := now();
	
begin
	raise notice '%', created_at;
	perform pg_sleep(10); -- 10 saniye bekleniyor
	raise notice '%', created_at; -- çıktıda aynı değer görünecek
	
end $$;

--********************* TABLODAN DATA TİPİNİ KOPYALAMA *******************
    /*
        -> variable_name  table_name.column_name%type;  
        ->( Tablodaki datanın aynı data türünde variable oluşturmaya yarıyor)
    */
    
do $$

declare
    film_title film.title%type;  -- varchar;     
	-- olusturdugum degiskenin data tipini dinamik yaptim
	
begin
    -- 1 id li filmin ismini getirelim
    select title
    from film
    into film_title  -- film_title = 'Kuzuların Sessizliği'
    where id=1;
    
    raise notice 'Film title id 1 : %' , film_title;
	
end $$ ;

--********************* İÇ İÇE BLOK YAPILARI *******************

do $$
<<outher_block>>
declare
	counter integer :=0;

begin
	counter := counter+1;
	raise notice 'The current value of counter is %',counter;
	
	declare
		counter integer :=0;
	begin
		counter :=counter+10;
		raise notice 'Counter in the subBlock is %',counter;
		raise notice 'Counter in the outher_block is %',outher_block.counter;
		--ic block tan dıs block a ulastık
	end;                                       
	
	raise notice 'Counter in the outher_block is %',counter;
	
end outher_block $$;

--********************* Row Type *******************

do $$

declare 
	selected_actor actor%rowtype ;
	
begin
	select *
	from actor
	into selected_actor -- id, isim, soyisim
	where id=1;
	
	raise notice 'The actor name is % %',
						selected_actor.isim,
						selected_actor.soyisim;
	
end $$;

-- *********************** Record Type *********************
	/*
		-> Row Type gibi çalışır ama record un tamamı değilde
		belli başlıkları almak istersek kullanılabilir
	*/
	
do $$

declare
	rec record;	--	record data turunde rec isminde variable olusturuldu
begin
	select id,title,type
	into rec
	from film
	where id=1;
	
	raise notice '% % %',rec.id,rec.title,rec.type;

end $$;

-- *********************** Constant *********************

do $$

declare
	vat constant numeric :=0.1; 
	net_price numeric:=20.5;

begin
	raise notice 'Satis fiyati : %', net_price*(1+vat);
    -- vat := 0.05; -- constant bir ifadeyi ilk setleme işleminden sonra değer değiştirmeye çalışırsak hata alırız
	
end $$;


-- constant bir ifadeye RT da değer verebilir miyim ???

do $$

declare
    start_at constant time := now();
	
begin
    raise notice 'bloğun çalışma zamanı : %', start_at;
	
end $$ ;

-- //////////////////// Control Structures ///////////////////////

-- ******************** If Statement ****************
-- syntax : 
/*
    if condition  then
            statement;
    end if ;
*/

-- Task : 1 id li filmi bulalım eğer yoksa ekrana uyarı yazısı verelim

do $$

declare
	istenen_film film%rowtype;
	istenen_filmId film.id%type:=1;
	
begin
	select * from film 
	into istenen_film
	where id=istenen_filmId;
	
	if not found then
		raise notice 'Girdiginiz id li film bulunamadı :%', istenen_filmId;
	
	end if;
	
end $$;

-- ************** IF-THEN-ELSE ****************

/*
    IF condition THEN
            statement;
    ELSE
            alternative statement;
    END IF
*/

-- Task : 1 idli film varsa title bilgisini yazınız yoksa uyarı yazısını ekrana basınız

do $$

declare

	selected_film film%rowtype;
	input_film_id film.id%type:=1; 

begin
	select * from film
	into selected_film
	where id=input_film_id;
	
	if not found then
			raise notice 'Girmis oldugunuz id li film bulunamadı : %',input_film_id;
		else
			raise notice 'Filmin ismi : %',selected_film.title;
	end if;

end $$;

-- ************* IF-THEN-ELSE-IF ************************
-- syntax : 
/*
    IF condition_1 THEN
                statement_1;
        ELSEIF condition_2 THEN
                statement_2;
        ELSEIF condition_3 THEN
                statement_3;
        ELSE 
                statement_final;
    END IF ;
*/
/*
    Task : 1 id li film varsa ; 
            süresi 50 dakikanın altında ise Short, 
            50<length<120 ise Medium, 
            length>120 ise Long yazalım
*/

do $$
declare
    v_film film%rowtype;
    len_description varchar(50);
begin
    select * from film
    into v_film  --- v_film.id = 1  / v_film.title ='Kuzuların Sessizliği'
    where id = 30;
    
    if not found then
        raise notice 'Film bulunamadı';
    else
        if v_film.length > 0 and v_film.length <=50 then
                len_description='Short';
            elseif v_film.length>50 and v_film.length<120 then
                len_description='Medium';
            elseif v_film.length>120 then
                len_description='Long';
            else
                len_description='Tanımlanamıyor';
         end if;
     	raise notice ' % filminin süresi : %', v_film.title, len_description;
     end if;            
end $$;

-- ******** Case Statement **************************
-- syntax : 
 
 /*
 
    CASE search-expression
     WHEN expression_1 [, expression_2,..] THEN
        statement
     [..]
     [ELSE
        else-statement]
     END case;
 */
 
-- Task : Filmin türüne göre çocuklara uygun olup olmadığını ekrana yazalım

do $$
declare
	uyari varchar(50);
	tur film.type%type;

begin
	select type from film
    into tur
    where id = 4;
	
	if found then 
		case tur
			when 'Korku' then uyari='Uygun degil';
			when 'Macera' then uyari='Uygun';
			when 'Animasyon' then uyari='Tavsiye edilir';
			else 
			uyari='Tanımlanamadı';
		end case ;
		raise notice '%',uyari;
	
	end if;
		
end $$;

-----------------------------08.03.2023 21:00-----------------------------

--Task 1 : Film tablosundaki film sayısı 10 dan az ise "Film sayısı az" yazdırın, 
--          10 dan çok ise "Film sayısı yeterli" yazdıralım

do $$
declare
	film_sayisi integer:=0;
begin
	select count(*) from film
	into film_sayisi; --film_sayisi=4
	
		if(film_sayisi<10) then
				raise notice 'Film sayısı az';
			else
				raise notice 'Film sayısı yeterli';
		end if;
end $$;

-- Task 2: user_age isminde integer data türünde bir değişken tanımlayıp default 
--  olarak bir değer verelim, If yapısı ile girilen değer 18 den büyük ise 
--  Access Granted, küçük ise Access Denied yazdıralım..

do $$
declare
	user_age integer:=17;
begin
	if(user_age>18) then
			raise notice 'Access Granted';
		else
			raise notice 'Access Denied';
	end if;

end $$;

-- Task 3: a ve b isimli integer türünde 2 değişken tanımlayıp default 
--  değerlerini verelim, eğer a nın değeri b den büyükse "a , b den büyüktür" 
--  yazalım, tam tersi durum için "b, a dan büyüktür" yazalım, iki değer 
--  birbirine eşit ise " a,  b'ye eşittir" yazalım: 

do $$
declare 
	a integer:=10;
	b integer:=20;

begin
	if a>b then
		raise notice 'a , b den büyüktür';
	elseif a<b then 
		raise notice 'b , a den büyüktür';
	elseif  a=b then
		raise notice 'a,  b ye eşittir';
	end if;		
end $$;


-- Task 4 : kullaniciYasi isimli bir değişken oluşturup default değerini verin, 
--  girilen yaş 18 den büyükse "Oy kullanabilirsiniz", 18 den küçük ise 
--  "Oy kullanamazsınız" yazısını yazalım.

do $$
declare
	kullaniciYasi int:=18;

begin
	if kullaniciYasi>=18 then
		raise notice 'Oy kullanabilirsiniz';
	else 
		raise notice 'Oy kullanamazsınız';
	end if;

end $$;

--  ************** LOOP *************************************

-- syntax 
LOOP
    statement;
END LOOP;

-- loop u sonlandırmak için loopun içine if yapısını kullanabilirz :
LOOP
    statements;
    IF condition THEN
        exit; -- loop dan çıkmamı sağlıyor
    END IF;
END LOOP;

-- nested loop 
<<outher>>
LOOP
    statements;
    <<inner>>
    LOOP
        .....
        exit <<inner>>
    END LOOP;
END LOOP;

-- Task : Fibonacci serisinde, belli bir sıradaki sayıyı ekrana getirelim
-- Fibonacci Serisi : 1,1,2,3,5,8,13,...

DO $$
DECLARE
    n integer :=40;      -->kacıncı sıradaki sayıyı istiyorsun?
    counter integer :=0;
    i integer :=0;       -->serideki eleman 1
    j integer :=1;	     -->serideki eleman 2
    fib integer :=0;     -->istenen cevap    
BEGIN 
    if(n<1) then
        fib:=0;
    end if;
    loop
        exit when counter =n;
        counter := counter +1;
        select j, (i+j) into i,j;   
    end loop;
    fib:=i;
    raise notice '%', fib;
    
END $$;

-- ************ WHILE LOOP *************************
syntax : 
WHILE condition LOOP
    statements;
END LOOP;
-- Task : 1 dan 4 e kadar counter değerlerini ekrana basalım

do $$

declare 
	counter integer :=0;
	n integer:=4;
	
begin
	while counter<n loop
		counter:=counter+1;
		raise notice '%',counter;
	end loop;
		
end $$;




		







 






















