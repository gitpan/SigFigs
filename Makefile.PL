use ExtUtils::MakeMaker;
WriteMakefile(
	NAME => "Math::SigFigs",
	VERSION_FROM => "SigFigs.pm",
	($] >= 5.005
	   ? (ABSTRACT   => 'Math using scientific significant figures',
	      AUTHOR     => 'Sullivan Beck (sbeck@cpan.org)')
	   : ()),
	'dist' => {COMPRESS=>'gzip',SUFFIX=>'gz'}
);
