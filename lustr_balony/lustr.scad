

//include <pcb_cnc_parameters.scad>
include <../../simulator/_libraries/globals.scad>

use <../../simulator/_libraries/cube/cube_rounded.scad>

use <../../simulator/_libraries/srouby/sroub_m3.scad>

include <../../simulator/_libraries/srouby/sroub_m4_defs.scad>
use <../../simulator/_libraries/srouby/sroub_m4.scad>

use <../../simulator/_libraries/stahovaci_pasek/stahovaci_pasek.scad>


zvetseni_otvoru_3d_tisk = 0.4;


blok_prumer               = 190;//130;
blok_vyska                = 35;
blok_pocet_hran           = 0;
blok_zaobleni             = 10;
blok_dno_vyska            = 5;

blok_vnitrni_prumer       = 120;
blok_vnitrni_vyska        = blok_vyska - blok_dno_vyska;


rameno_delka              = 90;  // Celková vzdalenost kabelu od stredu je rameno_delka + blok_vnitrni_prumer/2
rameno_sirka              = 20;
rameno_vyska              = 15;
rameno_polomer            = 2;
rameno_pocet              = 3;
rameno_uhel               = 360 / rameno_pocet;
ramena_otoceni            = 0;  // stupnu

// vybrani pro kabel
rameno_vybrani_vyska      = 10;
rameno_vybrani_sirka      = 8;
rameno_vybrani_polomer    = 2;

rameno_sroub_vzdalenost   = 15;
rameno_matka_zahloubeni   = 8;
rameno_vyska_bez_vybrani  = rameno_vyska - rameno_vybrani_vyska;

rameno_kruh_poloha        = 90;
rameno_kruh_prumer        = 130;
rameno_kruh_prodlouzeni   = 0;
rameno_kruh_zaobleni      = 10;


sokl_prumer               = blok_vnitrni_prumer - zvetseni_otvoru_3d_tisk*4;
sokl_vyska                = blok_vnitrni_vyska  - zvetseni_otvoru_3d_tisk;
sokl_sirka_steny          = 6;

hacek_sirka               = 35;
hacek_vyska               = 3;
hacek_sroub_prumer        = 6;

kabel_prumer              = 25;
kabel_vzdalenost_od_hacku = 42;
kabel_pocet_otvoru        = 3;
kabel_otvor_otoceni       = 60;  // stupnu

bajonet_sirka             = 10;
bajonet_vyska             = 10;
bajonet_zamek_vyska       = 1;
bajonet_zamek_uhel        = 15;
bajonet_zahloubeni        = 20;
bajonet_osazeni           = 3;

bajonet_pocet             = 3;
bajonet_uhel              = 360 / rameno_pocet;
bajonet_otoceni           = 60;  // stupnu



module sokl(){

  kabel_otvor_uhel = 360/kabel_pocet_otvoru;

  difference(){
    union(){
      difference(){
        union(){
          // Blok
          translate([0, 0, -sokl_vyska])
          cylinder(r=sokl_prumer/2, h=sokl_vyska);
          // Bajonety
          for (i = [0:bajonet_pocet-1]){
            translate([0, 0, -0.6]) // Posunuti bajonetu dolu o 0.6mm jako rezerva pro montaz
            rotate([0,0,i*bajonet_uhel+bajonet_otoceni])
            bajonet_oblouk(vyska = bajonet_vyska, sirka = bajonet_sirka, zvetseni = 0);
          }
        }
        // vybrani vnitrku
        translate([0, 0, -sokl_vyska-sokl_sirka_steny])
        cylinder(r=sokl_prumer/2-sokl_sirka_steny, h=sokl_vyska);
      }
      // Sloupek pro hacek
      translate([0, 0, -(hacek_vyska+sokl_sirka_steny)])
      cylinder(r=hacek_sirka/2+sokl_sirka_steny, h=hacek_vyska+sokl_sirka_steny);
    }
  
    // Otvor ve sloupku pro hacek
    translate([0, 0, -hacek_vyska+1])
    cylinder(r=hacek_sirka/2, h=hacek_vyska+1);

    // Otvor pro soub na hacek
    translate([0, 0, -sokl_vyska*2])
    cylinder(r=hacek_sroub_prumer/2, h=sokl_vyska*3);

    // Otvory pro kabel
    for (i = [0:kabel_pocet_otvoru-1]){
      rotate([0,0,i*kabel_otvor_uhel+kabel_otvor_otoceni])
      translate([kabel_vzdalenost_od_hacku, 0, -sokl_sirka_steny*2])
      cylinder(r=kabel_prumer/2, h=sokl_sirka_steny*3);
    }
    // Vybrani pro kabely
    for (i = [0:rameno_pocet-1]){
      rotate([0,0,i*rameno_uhel+ramena_otoceni])
      translate([blok_vnitrni_prumer/2-25, -rameno_sirka-6, -sokl_vyska*2])
      cube([rameno_delka, rameno_sirka*2-3, sokl_vyska*3]);
    }
  }
} // sokl


module blok(zjednoduseny = 0){

  difference(){
    translate([0, 0, -blok_vyska])
    if (blok_pocet_hran > 2){
      if (blok_zaobleni > 0 && zjednoduseny == 0) {
        cylinder_rounded(r=blok_prumer/2, h=blok_vyska, r_zaobleni=blok_zaobleni, pocet_hran = blok_pocet_hran);
      } else {
        cylinder(r=blok_prumer/2, h=blok_vyska, $fn=blok_pocet_hran);
      }
    } else {
      if (blok_zaobleni > 0 && zjednoduseny == 0) {
        cylinder_rounded(r=blok_prumer/2, h=blok_vyska, r_zaobleni=blok_zaobleni, pocet_hran = 0);
      } else {
        cylinder(r=blok_prumer/2, h=blok_vyska);
      }
    }
    // Vnitrni orvor
    translate([0, 0, -blok_vnitrni_vyska])
    cylinder(r=blok_vnitrni_prumer/2, h=blok_vnitrni_vyska*2);

    for (i = [0:rameno_pocet-1]){
      rotate([0,0,i*rameno_uhel+ramena_otoceni])
      union(){
        if (zjednoduseny > 0) {
          // otvory pro ramena - zjednodusena varianta
          translate([blok_vnitrni_prumer/2-10, -rameno_sirka/2-zvetseni_otvoru_3d_tisk, -rameno_vyska-zvetseni_otvoru_3d_tisk])
          cube([rameno_delka, rameno_sirka+2*zvetseni_otvoru_3d_tisk, rameno_vyska*2]);
        } else {
          // otvory pro ramena
          translate([blok_vnitrni_prumer/2, 0, 0])
          rameno(obrys = 1, zvetseni = 1);
        }
        // otvor pro sroub pro prisroubovani ramena
        translate([blok_vnitrni_prumer/2+rameno_sroub_vzdalenost, 0, -rameno_vyska])
        sroub_m4_otvor_pro_valec(delka_sroub = blok_vyska-rameno_vyska-1, delka_hlava = rameno_vyska);
        // otvor pro matku - bocni pruchod
        translate([blok_vnitrni_prumer/2+rameno_sroub_vzdalenost+2, 0, -rameno_vyska-matka_m4_zahloubeni-zvetseni_otvoru_3d_tisk-rameno_matka_zahloubeni])
        rotate([0,0,180])
        sroub_m4_matka_plus_bocni_pruchod(pruchod_delka = blok_vnitrni_prumer, matka_vyska = matka_m4_zahloubeni);
      }
    }
    if (zjednoduseny == 0) {
      // Otvory pro bajonety
      for (i = [0:bajonet_pocet-1]){
        rotate([0,0,i*bajonet_uhel+bajonet_otoceni])
        bajonet_otvor(zvetseni = zvetseni_otvoru_3d_tisk);
      }
      // Otvory pro stahovaci pasky
      for (i = [0:rameno_pocet-1]){
        rotate([0,0,i*rameno_uhel+ramena_otoceni])
        translate([blok_vnitrni_prumer/2, 0, -rameno_vyska-4])
        rotate([0,90,0])
        stahovaci_pasek_otvor();
      }
    }
  }

  // zaslepeni otvoru pro sroub/matku pro 3d tisk
  for (i = [0:rameno_pocet-1]){
    rotate([0,0,i*rameno_uhel+ramena_otoceni])
    translate([blok_vnitrni_prumer/2+rameno_sroub_vzdalenost, 0, -rameno_vyska-zvetseni_otvoru_3d_tisk-rameno_matka_zahloubeni])
    cylinder(r=4, h=vyska_vrstvy);
  }
} // blok


module rameno(obrys = 0, zvetseni = 1){

  obrys_zvetseni      = obrys * zvetseni;
  rameno_prodlouzeni  = obrys * 10;

  difference(){
    union(){
      difference(){
        union(){
          difference(){
            translate([-rameno_prodlouzeni, -rameno_sirka/2-obrys_zvetseni/2, -rameno_vyska-obrys_zvetseni])
            if (rameno_polomer > 0 && obrys_zvetseni == 0) {
              cuber(rameno_delka+rameno_prodlouzeni, rameno_sirka+obrys_zvetseni, rameno_vyska*2,r=rameno_polomer, dim=2);
            } else {
              cube([rameno_delka+rameno_prodlouzeni, rameno_sirka+obrys_zvetseni, rameno_vyska*2]);
            }
            // horni seriznuti
            translate([-50, -rameno_sirka/2-10, obrys_zvetseni])
            cube([rameno_delka+100, rameno_sirka+20, rameno_vyska*2]);
          }
          // kruh na ramene
          //difference()
          {
            translate([rameno_kruh_poloha, 0, -rameno_vyska-obrys_zvetseni])
            resize([(rameno_kruh_prumer/2+obrys_zvetseni)*2+rameno_kruh_prodlouzeni,(rameno_kruh_prumer/2+obrys_zvetseni)*2,rameno_vyska+obrys_zvetseni*2])
            if (rameno_kruh_zaobleni > 0 && obrys_zvetseni == 0) {
              cylinder_rounded(r=rameno_kruh_prumer/2+obrys_zvetseni, h=rameno_vyska+obrys_zvetseni*2, r_zaobleni=rameno_kruh_zaobleni, pocet_hran = 0);
            } else {
              cylinder(r=rameno_kruh_prumer/2+obrys_zvetseni, h=rameno_vyska+obrys_zvetseni*2);
            }
            // vnitrni oriznuti
//             translate([-blok_vnitrni_prumer/2, 0, -blok_vyska*2])
//             cylinder(r=blok_prumer/2-10-obrys_zvetseni, h=blok_vyska*3);
          }
        }
        if (obrys == 0) {
          // vybrani pro kabel
          translate([-10, -rameno_vybrani_sirka/2, -rameno_vybrani_vyska])
          cuber(rameno_delka+20, rameno_vybrani_sirka, rameno_vybrani_vyska*2,r=rameno_vybrani_polomer, dim=2);
          // zkoseni leveho konce vybrabi pro zaobleni
          translate([0, 0, -rameno_vyska])
          rotate([0,-45,0])
          translate([0, -rameno_vybrani_sirka/2, 0])
          cube([rameno_vyska, rameno_vybrani_sirka, rameno_vyska]);
          // zkoseni praveho konce vybrabi pro zaobleni
          translate([rameno_delka, 0, -rameno_vyska])
          rotate([0,-45,0])
          translate([0, -rameno_vybrani_sirka/2, 0])
          cube([rameno_vyska, rameno_vybrani_sirka, rameno_vyska]);
        }
      }
      // zaobleni leveho konce pro kabel
      intersection(){
        // zaobleni
        translate([rameno_vyska_bez_vybrani, rameno_vybrani_sirka/2+1, -rameno_vyska])
        rotate([90,0,0])
        cylinder(r=rameno_vyska_bez_vybrani, h=rameno_vybrani_sirka+2);
        // orez valce do jednoho kvadrantu
        translate([0, -rameno_vybrani_sirka/2-1, -rameno_vyska])
        cube([rameno_vyska_bez_vybrani, rameno_vybrani_sirka+2, rameno_vyska_bez_vybrani]);
      }
      // zaobleni praveho konce pro kabel
      intersection(){
        // zaobleni
        translate([rameno_delka-rameno_vyska_bez_vybrani, rameno_vybrani_sirka/2+1, -rameno_vyska])
        rotate([90,0,0])
        cylinder(r=rameno_vyska_bez_vybrani, h=rameno_vybrani_sirka+2);
        // orez valce do jednoho kvadrantu
        translate([rameno_delka-rameno_vyska_bez_vybrani, -rameno_vybrani_sirka/2-1, -rameno_vyska])
        cube([rameno_vyska_bez_vybrani, rameno_vybrani_sirka+2, rameno_vyska_bez_vybrani]);
      }
    }
    if (obrys == 0) {
      // otvor pro sroub
      translate([rameno_sroub_vzdalenost, 0, -rameno_vybrani_vyska-1])
      sroub_m4_otvor_pro_zapustnou_hlavu(delka_sroub = rameno_vyska, delka_hlava = rameno_vyska);
      // otvor pro kabel
      translate([rameno_delka, 0, -rameno_vyska*2])
      cylinder(r=rameno_vybrani_sirka/2, h=rameno_vyska*3);
    }
  }
} // rameno



module ramena(){

  for (i = [0:rameno_pocet-1]){
    rotate([0,0,i*rameno_uhel+ramena_otoceni])
    translate([blok_vnitrni_prumer/2, 0, 0])
    rameno();
  }
} // ramena


module srouby(){

  for (i = [0:rameno_pocet-1]){
    rotate([0,0,i*rameno_uhel+ramena_otoceni])
    translate([blok_vnitrni_prumer/2, 0, 0])
    translate([rameno_sroub_vzdalenost, 0, -rameno_vybrani_vyska])
    sroub_m4_otvor_pro_zapusnou_hlavu(delka_sroub = 20, delka_hlava = rameno_vyska);
  }

//   for (i = [0:rameno_pocet-1]){
//     rotate([0,0,i*rameno_uhel+ramena_otoceni])
//     // otvor pro sroub pro prisroubovani ramena
//     translate([blok_vnitrni_prumer/2+rameno_sroub_vzdalenost, 0, -rameno_vyska])
//     sroub_m4_otvor_pro_valec(delka_sroub = blok_vyska-rameno_vyska-1, delka_hlava = rameno_vyska);
//   }

} // srouby




module bajonet_otvor(zvetseni = 0){

  difference(){
    union(){
      bajonet_oblouk(vyska = sokl_vyska, sirka = bajonet_sirka, zvetseni = zvetseni);
  
      rotate([0,0,bajonet_zamek_uhel])
      bajonet_oblouk(vyska = bajonet_vyska + bajonet_zamek_vyska, sirka = bajonet_sirka, zvetseni = zvetseni);
  
      for (i = [0:bajonet_zamek_uhel-1]){
        rotate([0,0,i])
        bajonet_oblouk(vyska = bajonet_vyska, sirka = bajonet_sirka, zvetseni = zvetseni);
      }
    }

    rotate([0,0,5.7])
    bajonet_oblouk_zaslepeni(vyska = bajonet_vyska, sirka = 0.8, zvetseni = 0.2);

    rotate([0,0,9.6])
    bajonet_oblouk_zaslepeni(vyska = bajonet_vyska, sirka = 0.8, zvetseni = 0.2);
  }
}

module bajonet_oblouk(vyska = bajonet_vyska, sirka = bajonet_sirka, zvetseni = 0){
  translate([0, 0, -bajonet_zahloubeni])
  translate([0, -sirka/2-zvetseni, -zvetseni])
  cube([sokl_prumer/2+bajonet_osazeni+zvetseni, sirka+zvetseni*2, vyska+zvetseni*2]);
}

module bajonet_oblouk_zaslepeni(vyska = bajonet_vyska, sirka = bajonet_sirka, zvetseni = 0){
  translate([0, 0, -bajonet_zahloubeni])
  translate([0, -sirka/2-zvetseni, -zvetseni*3])
  cube([sokl_prumer/2+bajonet_osazeni+zvetseni, sirka, vyska+zvetseni*6]);
}


module cylinder_with_ball(r=10, h=20){
  translate([0, 0, r]){
    cylinder(r=r, h=h-r);
    sphere(r = r);
  }
}

module cylinder_rounded(r=100, h=20, r_zaobleni=10, pocet_hran = 0){
  if (pocet_hran > 2) {
    uhel_krok = 360/pocet_hran;
    hull(){
      for (i = [0:pocet_hran-1]){
        rotate([0,0,uhel_krok*i])
        translate([r-r_zaobleni, 0, 0])
        cylinder_with_ball(r=r_zaobleni, h=h);
      }
    }
  } else {
    translate([0, 0, r_zaobleni/2]){
      cylinder(r=r, h=h-r_zaobleni/2);
      hull(){
        rotate_extrude(angle=360) {
          translate([r - r_zaobleni/2, 0])
          circle(d=r_zaobleni);
        }
      }
    }
  }
}

//bajonet_otvor(zvetseni = 0);


// %bajonet_otvor(zvetseni = 1);


//cylinder_rounded(r=100, h=60, r_zaobleni=20, pocet_hran = 0);


//blok();
//ramena();

// %translate([blok_vnitrni_prumer/2, 0, 0])
//rameno(obrys = 1, zvetseni = 1);

// translate([blok_vnitrni_prumer/2, 0, 0])
//rameno();

blok();
//ramena();

//srouby();

//
//rotate([0,0,bajonet_zamek_uhel])
//translate([0, 0, 40])
//sokl();


