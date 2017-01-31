$preview_mode = 0;
$pdf_mode = 1;
$pdf_previewer = 'xdg-open %O %S';
# $pdflatex = 'pdflatex -synctex=1 --shell-escape %O %S';
$pdflatex = 'xelatex --shell-escape %O %S';
# # Custom dependency and function for nomencl package 
add_cus_dep( 'nlo', 'nls', 0, 'makenlo2nls' );
sub makenlo2nls {
    system( "makeindex -s nomencl.ist -o \"$_[0].nls\" \"$_[0].nlo\"" );
}

# for nomenclature
# add_cus_dep("nlo", "nls", 0, "nlo2nls");
# sub nlo2nls {
    # system("makeindex $_[0].nlo -s nomencl.ist -o $_[0].nls -t $_[0].nlg");
# }
add_cus_dep('glo', 'gls', 0, 'run_makeglossaries');
add_cus_dep('acn', 'acr', 0, 'run_makeglossaries');

sub run_makeglossaries {
    if ( $silent  ) {
        system "makeglossaries -q \"$_[0]\"";
    }
    else {
        system "makeglossaries \"$_[0]\"";
    };
}
push @generated_exts, 'glo', 'gls', 'glg';
push @generated_exts, 'acn', 'acr', 'alg';
$clean_ext .= ' %R.ist %R.xdy';
