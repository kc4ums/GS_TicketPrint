#!/usr/bin/perl

#	Langboard Inc.
# 	Tim Gray - Jan 17,2018
#
# linux programs required:
#
# perl  - larry wall's practical extraction and report language
# perl-tk - perl module providing the tk graphics library
# gv - postscript and pdf viewer for x 
# ghostscript - the gpl ghostscript postscript/pdf interpreter
# libstring-crc32-perl - perl interface for cyclic redundancy check generation
# xsltproc - xslt 1.0 command line processor
# coreutils - gnu core utilities
# sed - the gnu sed stream editor
# mysql-admin - gui tool for intuitive mysql administration
# libdbi-perl - perl database interface (dbi)
# sam2p -  convert raster images to eps, pdf, and other formats
# ps2pdf - 
# perl modules required from http:://www.cpan.org :
#
# Tk::DateEntry - cpan
# Imager::QRCode - cpan 
# String::CRC32

$version = 'linux 1.11';

use Imager::QRCode;
use Tk;
use Tk::DateEntry;  #cpan repository
use String::CRC32;  #synaptic package manager
use DBI;

$printer = "HP_LaserJet_M605";
#$printer = "c88";


$debug = 0;

if( $debug == 1){
    $grade = "IND";
    $thickness = "3/4";
    $width = "97";
    $length = "109";
    $shift_produced = "A";
    $shift_sanded = "B";
    $shift_sawed = "C";
    $date_produced = "2013-01-01";
    $date_sanded = "2013-01-02";
    $date_sawed = "2013-01-03";
    $piece_count = "123";
    $unit_number = "23";
}


# lock the program so it cannot be run again if already open
#use Fcntl ':flock'; # import LOCK_* constants
#INIT{
#open  *{0}
#or die "What!? $0:$!";
#flock *{0}, LOCK_EX|LOCK_NB
#or die "$0 is already running somewhere!n";
#}


# main window
my $mw = MainWindow->new;
$mw->geometry("675x300");
$mw->title('Langboard Inc. - Sawline Ticket Print For TLC Mouldings <Linux Version>');

# make the widgets
# l = label
# e = entry

my $l_qrcode = $mw -> Checkbutton(-text=>"Include QR Code",
	-variable=>\$e_qrcode);

my $l_title = $mw->Label(-text=> '');

my $l_grade = $mw->Label(-text=> 'Grade');
my $e_grade = $mw->Entry(-width=> 13,-textvariable => \$grade);

my $l_thickness = $mw->Label(-text => 'Thickness');
my $e_thickness = $mw->Entry(-width => 13,-textvariable => \$thickness);
my $l_width = $mw->Label(-text => 'Width');
my $e_width = $mw->Entry(-width => 13,-textvariable => \$width);
my $l_length = $mw->Label(-text => 'Length');
my $e_length = $mw->Entry(-width => 13,-textvariable => \$length);
my $l_piece_count = $mw->Label(-text => 'Piece Count');
my $e_piece_count = $mw->Entry(-width => 13,-textvariable => \$piece_count);

my $l_date_produced = $mw->Label(-text => 'Date Produced');
my $e_date_produced = $mw->DateEntry(-weekstart=>1,-daynames=>[qw/sun mon tue wed thu fri sat/],-dateformat => 4,-textvariable => \$date_produced,);
my $l_shift_produced = $mw->Label(-text => 'Shift Produced');
my $e_shift_produced = $mw->Entry(-width => 13,-textvariable => \$shift_produced);

my $l_date_sanded = $mw->Label(-text => 'Date Sanded');
my $e_date_sanded = $mw->DateEntry(-weekstart=>1,-daynames=>[qw/sun mon tue wed thu fri sat/],-dateformat => 4,-textvariable => \$date_sanded,); 
my $l_shift_sanded = $mw->Label(-text => 'Shift Sanded');
my $e_shift_sanded = $mw->Entry(-width => 13,-textvariable => \$shift_sanded);
my $l_grit = $mw->Label(-text => 'belt grit');
my $e_grit = $mw->Entry(-width => 13,-textvariable => \$grit);

my $l_date_sawed = $mw->Label(-text => 'Date Sawed');
my $e_date_sawed =  $mw->DateEntry(-weekstart=>1,-daynames=>[qw/sun mon tue wed thu fri sat/],-dateformat => 4,-textvariable => \$date_sawed,);
my $l_shift_sawed = $mw->Label(-text => 'Shift Sawed');
my $e_shift_sawed = $mw->Entry(-width => 13,-textvariable => \$shift_sawed);

my $l_unit_number = $mw->Label(-text => 'Unit Number');
my $e_unit_number = $mw->Entry(-width => 13,-textvariable => \$unit_number);

my $l_po_number = $mw->Label(-text => 'PO Number');
my $e_po_number = $mw->Entry(-width => 13,-textvariable => \$po_number);

my $l_print_number = $mw->Label(-text => '# of Tickets');
my $e_print_number = $mw->Entry(-width => 13,-textvariable => \$print_number);
$print_number = 1;

my $preview = $mw->Button(-text => 'Preview', -command => [\&preview]);
my $print = $mw->Button(-text => 'Print', -command => [\&print]);
my $cancel = $mw->Button(-text => 'Clear Queue', -command => [\&cancel]);


# place the widgets on the grid

$l_title->grid(-row => 2, -column => 0);
$l_qrcode->grid(-row => 1, -column => 0);
$preview->grid(-row => 1, -column => 1);
$l_print_number->grid(-row => 1, -column => 2);
$e_print_number->grid(-row => 1, -column => 3);
$print->grid(-row => 1, -column => 4);
$cancel->grid(-row => 1, -column => 5);

$l_grade->grid(-row => 3, -column => 0);
$e_grade->grid(-row => 3, -column => 1);

$l_thickness->grid(-row => 4, -column => 0);
$e_thickness->grid(-row => 4, -column => 1);
$l_width->grid(-row => 5, -column => 0);
$e_width->grid(-row => 5, -column => 1);

$l_length->grid(-row => 6, -column => 0);
$e_length->grid(-row => 6, -column => 1);

$l_piece_count->grid(-row => 8, -column => 0);
$e_piece_count->grid(-row => 8, -column => 1);

$l_date_produced->grid(-row => 10, -column => 0);
$e_date_produced->grid(-row => 10, -column => 1);
$l_shift_produced->grid(-row => 10, -column => 2);
$e_shift_produced->grid(-row => 10, -column => 3);

$l_date_sanded->grid(-row => 11, -column => 0);
$e_date_sanded->grid(-row => 11, -column => 1);
$l_shift_sanded->grid(-row => 11, -column => 2);
$e_shift_sanded->grid(-row => 11, -column => 3);

$l_date_sawed->grid(-row => 12, -column => 0);
$e_date_sawed->grid(-row => 12, -column => 1);
$l_shift_sawed->grid(-row => 12, -column => 2);
$e_shift_sawed->grid(-row => 12, -column => 3);

$l_unit_number->grid(-row => 13, -column => 0);
$e_unit_number->grid(-row => 13, -column => 1);
$l_po_number->grid(-row => 13, -column => 2);
$e_po_number->grid(-row => 13, -column => 3);



MainLoop;

# sub to make the postscript file and preview and print with ghost view
sub preview{

    &crc;
    
    if ($e_qrcode == 1) {
	&qrcode;
    }
      
    
    &ghostscript;
    
    
    if ($e_qrcode == 1) {
	&insert_qrcode;
    } else {
	&no_qrcode;
    }
    
    #system("gv -media legal -scale .500 \GSTicketPage.ps");
    system("ps2pdf -dAutoRotatePages=/None  -dPaperSize=/Legal GSTicketPage.ps GSTicketPage.pdf");
    system("gv -media legal -scale .500 \GSTicketPage.pdf");
    
    
}




sub print{
    &crc;
    
    if ($e_qrcode == 1) {
	&qrcode;
    }
      
    &ghostscript;
        
    if ($e_qrcode == 1) {
	&insert_qrcode;
    } else {
	&no_qrcode;
    }

   system("ps2pdf -dAutoRotatePages=/None  -dPaperSize=/Legal   GSTicketPage.ps GSTicketPage.pdf");


     #my $command = "lpr -#"  .  $print_number . " GSTicketPage.ps";
     #my $command = "lp -d " . $printer . " -n"  . $print_number . " GSTicketPage.pdf";
     my $command = "lp -d " . $printer . " -n"  . $print_number . " GSTicketPage.ps";
    

    system($command);

    &sql_insert;   
    

}

sub cancel{

    system("lprm - ");

}



sub ghostscript{
# generate ghostscript file
$ghostscript_file = "GSTicketPage.ps"; # name of the postscript file and path

open(FILE, "> $ghostscript_file");
print FILE "
 %!
  
  gsave clippath pathbbox grestore
  4 dict begin
  /ury exch def /urx exch def /lly exch def /llx exch def
  90 rotate  llx neg               llx urx sub lly sub  translate  % llx,lly
  % end of rotating to landscape

0 0 0 setrgbcolor


  %main ticket *** large grade print 
  /Helvetica-Bold findfont 52 scalefont  setfont
 
  55 350  moveto
  ($grade) show
  
  %maint ticket **** large thick,width, piece count & length
  /Helvetica-Bold findfont 52 scalefont setfont
  
  55 295 moveto
  ($thickness) show
  320 295 moveto
  ($piece_count) show
  55 240 moveto
 /Helvetica-Bold findfont 28 scalefont setfont
  ($width) show
  320 240 moveto
 /Helvetica-Bold findfont 28 scalefont setfont
  ($length) show
 
 
 % main ticket **** small shift and date info 
  /Helvetica findfont 15 scalefont setfont
  
   140 214 moveto
  ($shift_produced) show
  157 214 moveto
  ($date_produced) show
 
  140 196 moveto
  ($shift_sanded) show
  157 196 moveto
  ($date_sanded) show
  
  385 214 moveto
  ($shift_sawed) show
  405 214 moveto
  ($date_sawed) show

  385 196 moveto
  ($unit_number) show
 
  % tear off ticket **** small shift and date info 
  /Helvetica findfont 11 scalefont setfont

  40 40 moveto
  (PRO:) show
  80 40 moveto
  ($shift_produced) show
  90 40 moveto
  ($date_produced) show
  40 30 moveto
  (SND:) show  
  80 30 moveto
  ($shift_sanded) show
  90 30 moveto
  ($date_sanded) show
  40 20 moveto
  (SAW:) show
  80 20 moveto
  ($shift_sawed) show
  90 20 moveto
  ($date_sawed) show
  425 10 moveto
  ($crc) show


  175 40 moveto
  (THK:) show
  215 40 moveto
  ($thickness) show
  
  175 30 moveto
  (WID:) show
  215 30 moveto
 ($width) show
  175 20 moveto
  (LEN:) show  
   215 20 moveto
  ($length) show


  290 40 moveto
  (GRD:) show
  330 40 moveto
  ($grade) show
  290 30 moveto
  (PCS:) show
  330 30 moveto
  ($piece_count) show
  290 20 moveto
  (UNT:) show
  330 20 moveto
  ($unit_number) show

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%  right hand side %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %main ticket *** large grade print 
  /Helvetica-Bold findfont 52 scalefont  setfont
 
  560 350  moveto
  ($grade) show
  
  %maint ticket **** large thick,width, piece count & length
  /Helvetica-Bold findfont 52 scalefont setfont
  
  560 295 moveto
  ($thickness) show
  825 295 moveto
  ($piece_count) show
  560 240 moveto
  /Helvetica-Bold findfont 28 scalefont setfont
  ($width) show
  825 240  moveto
 /Helvetica-Bold findfont 28 scalefont setfont
 ($length) show
 
 
 % main ticket **** small shift and date info 
  /Helvetica findfont 15 scalefont setfont
  
   648 214 moveto
  ($shift_produced) show
  663 214 moveto
  ($date_produced) show
 
  648 196 moveto
  ($shift_sanded) show
  663 196 moveto
  ($date_sanded) show
  
  892 214 moveto
  ($shift_sawed) show
  912 214 moveto
  ($date_sawed) show

  892 196 moveto
  ($unit_number) show
 
  % tear off ticket **** small shift and date info 
  /Helvetica findfont 11 scalefont setfont

  540 40 moveto
  (PRO:) show
  580 40 moveto
  ($shift_produced) show
  590 40 moveto
  ($date_produced) show
  540 30 moveto
  (SND:) show  
  580 30 moveto
  ($shift_sanded) show
  590 30 moveto
  ($date_sanded) show
  540 20 moveto
  (SAW:) show
  580 20 moveto
  ($shift_sawed) show
  590 20 moveto
  ($date_sawed) show


  675 40 moveto
  (THK:) show
  715 40 moveto
  ($thickness) show
  
  675 30 moveto
  (WID:) show
  715 30 moveto
  ($width) show
  675 20 moveto
  (LEN:) show  
  715 20 moveto
  ($length) show


  790 40 moveto
  (GRD:) show
  830 40 moveto
  ($grade) show
  790 30 moveto
  (PCS:) show
  830 30 moveto
  ($piece_count) show
  790 20 moveto
  (UNT:) show
  830 20 moveto
  ($unit_number) show
 
  925 10 moveto
  ($crc) show



%%%%%% the system calls below append the qrcode image 
%%%%%% plus the showpage


";


close(FILE);
}



sub no_qrcode{
    system("echo showpage >> GSTicketPage.ps");
    #system("gv -media legal -scale .500 \GSTicketPage.ps");
}



sub insert_qrcode{
    system("cat  GSTicketPage.ps qrcode.eps >> GSTicketPage.ps");
    system("sed -i 's/BoundingBox: [0-9]*[0-9] [0-9]*[0-9] [0-9]*[0-9] [0-9]*[0-9]/BoundingBox: 0 0 400 400/g' GSTicketPage.ps");
    system("sed -i 's/Matrix\[1 0 0 -1 [0-9]*[0-9] [0-9]*[0-9]\]/Matrix[1 0 0 -1 -223 320]/g' GSTicketPage.ps");
    #system("gv -media LEGAL -scale .500 \GSTicketPage.ps");
}




sub crc{
# generate crc used for porduct code
$crc = crc32("105" .  $grade . $thickness .  $width . $length . $piece_count . $shift_produced  . $date_produced  .  $shift_sanded  . $date_sanded  . $shift_sawed . $date_sawed);


$xml = $crc;
open(WWW_PAGE, ">/var/www/products/xml/" . $xml .".xml");
print WWW_PAGE (<<EOF);
<?xml version="1.0"?>
    <?xml-stylesheet href="product.xsl" type="text/xsl"?>
    <langboard>
    <mill>105</mill>
    <company>Langboard Inc.</company>
    <crc>$crc</crc>
    <product>
      <grade>$grade</grade>
      <thickness>$thickness</thickness>
      <width>$width</width>
      <length>$length</length>
      <unit_number></unit_number>
      <piece_count>$piece_count</piece_count>
    </product>
    
    <production>
      <date_produced>$date_produced</date_produced>
      <date_sanded>$date_sanded</date_sanded>
      <date_sawed>$date_sawed</date_sawed>
      <shift_produced>$shift_produced</shift_produced>
      <shift_sanded>$shift_sanded</shift_sanded>
      <shift_sawed>$shift_sawed</shift_sawed>
    </production>
    </langboard>
EOF
;

close WWW_PAGE;

system("xsltproc /var/www/products/xml/" . $crc . ".xml  -o /var/www/products/" . $crc . ".html");

}



sub qrcode{
# Generate QR Code
    my $qrcode = Imager::QRCode->new(
        size          => 2,
        margin        => 2,
        version       => 1,
        level         => 'M',
        casesensitive => 1,
        lightcolor    => Imager::Color->new(255, 255, 255),
        darkcolor     => Imager::Color->new(0, 0, 0),
    );
my $img = $qrcode->plot("http://langboardmdf.dyndns.org:9990/products/" . $crc . ".html");

$img->write(file => "/home/ticket/qrcode.png");
system("sam2p /home/ticket/qrcode.png /home/ticket/qrcode.eps");  
}




sub sql_insert{

$database =  "db_ticket";
$user = "ticket";
$pass = "ticket";
$host = "localhost";

   
    my $dbh = DBI->connect("DBI:mysql:database=$database;host=$host",
			   $user, $pass,
			   {'RaiseError' => 1});
    
   my $statement =   "INSERT INTO ticket (crc,grade,thickness,width,length,piece_count,unit_number,date_produced,shift_produced,date_sanded,shift_sanded,date_sawed,shift_sawed,po_number) VALUES \('" . $crc . "','" . $grade . "','" . $thickness . "','" . $width  . "','" . $length  . "','" . $piece_count  . "','" . $unit_number  . "','" . $date_produced  . "','" . $shift_produced  . "','" . $date_sanded  . "','" . $shift_sanded  . "','" . $date_sawed  . "','" .  $shift_sawed  . "','" . $po_number . "'\)" ;
    

if($debug == 1){
print "\n";
print $statement;

}
    
    my $sth = $dbh->prepare($statement);
    my $rows = $sth->execute();


}


