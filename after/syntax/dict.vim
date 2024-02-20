if v:version < 600
    syntax clear
elseif exists('b:current_syntax')
    finish
endif

" NoMatches Found Header
syn match noMatchesHeader '^No definitions found for ".\+"' nextgroup=noMatchesWord
syn match noMatchesWord containedin=noMatchesHeader contained  '\("\)\@<=\(.\+\)\("\)\@='

syn match noMatchesPerhaps '^\w\+:.\+$'
syn match noMatchesOrigin '^\w\+:'

" Matches Found Header
syn match matchesHeader '^[0-9]\+ \(definition\|definitions\) found for ".\+"' nextgroup=matchesCount
syn match matchesCount containedin=matchesHeader contained '^[0-9]\+' nextgroup=matchesLabel
syn match matchesLabel containedin=matchesHeader contained '\(definition\|definitions\) found for' nextgroup=matchesWord
" Injected text
syn match matchesWord containedin=matchesHeader contained  '\("\)\@<=\(.\+\)\("\)\@='

syn match matchOrigin '^From .\+:'
syn match word '^\s\{2}\w\+\(\s\w\+\)*'
syn match wordType '\(\s\|,\)\@<=\(t\|i\|a\|adj\|adv\|n\|v\)\.'

" up here to catch values outside of blocks / quotes
syn match otherWord  '{.\{-\}}'
syn match textSource '^\s\{5\}\s\+\[.\+\]$'
syn match detailsSubLabel '^\s\{8\}\((\w)\)\(\s\S\)\@='

syn match pronounce '\(\s\)\@<=\(\/\S\+\/\|\\\S\+\\\)\(,\|\s\)' nextgroup=wordPronounce
syn match wordPronounce containedin=pronounce contained '\/\S\+\/\|\\\S\+\\'

" gcide specific
syn match detailBlock '^\s\{5\}\S\(.\+\n\s\{8\}\)\+.\+' nextgroup=detailsLabel,detailsKeyword,textSource,otherWord

" syn match detailBlock     '\n\s\{5\}\S.\+\n' nextgroup=detailsLabel,detailsKeyword,textSource
syn match detailBlock '\(\s\{2}\n\)\@<=\(\s\{5\}.\+\)\(\n\s\{2\}\n\)\@=' nextgroup=detailsLabel,detailsKeyword,textSource

syn match detailsLabel containedin=detailBlock contained '^\s\{5\}\([0-9]\+\.\|{\w\+\( \w\+\)*}\|\w\+:\)'

syn match detailsKeyword containedin=detailBlock contained '^\s\{5\}\w\+:' nextgroup=detailsNote,detailsSyn,detailsUsage
syn match detailsNote 'Note:' contained
syn match detailsSys 'Syn:' contained
syn match detailsUsage 'Usage:' contained

syn match detailsSubLabel containedin=detailBlock contained '^\s\{8\}\((\w)\)\(\s\S\)\@='

syn match otherWord  containedin=detailBlock   '{.\{-\}}'

syn match textSource containedin=detailBlock contained '^\s\+\[.\+\]$'

syn match quoteBlock '\(\s*\n\)\@<=\(\s\{10\}\s*\(.\+\n\)\{-}\)\(\s*$\|\s\{8\}\)\@=' nextgroup=quoteSource,textSource
" single line
" multi line
syn match quoteSource containedin=quoteBlock contained '\(--.\+\(\n\s\{14\}.\+\)*\)\(\n\s\+\[\)\@='

syn match textSource containedin=quoteBlock contained '^\s\+\[.\+\]$'

" jargon specific
syn match jargonBlock '^\s\{6\}\S\(.\+\n\s\{6\}\)*.\+' nextgroup=jargonLabel,jargonOtherWord
syn match jargonLabel containedin=jargonBlock contained '\(\s\{2\}\n\)\@<=\(^\s\{6\}\([0-9]\+\.\)\)'
syn match jargonOtherWord  contained containedin=jargonBlock   '{.\{-\}}'

if version >= 508 || !exists("did_dict_syn_inits")
  if version < 508
    let did_dict_syn_inits = 1
      command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink noMatchesHeader  Title
  HiLink noMatchesWord    Identifier
  HiLink noMatchesOrigin  PreProc

  HiLink matchesHeader    Title
  HiLink matchesCount     Title
  HiLink matchesLabel     Title
  HiLink matchesFor       Title
  HiLink matchesWord      Identifier

  HiLink matchOrigin      PreProc

  HiLink word             Identifier
  HiLink wordType         Type
  HiLink wordPronounce    Typedef

  HiLink otherWord        Keyword
  HiLink jargonOtherWord  Keyword


  HiLink detailsLabel     PreProc
  HiLink detailsKeyword   Todo
  HiLink detailsSubLabel  PreProc

  HiLink textSource       Special
  HiLink quoteSource      Define

  HiLink jargonLabel      PreProc

  delcommand HiLink
endif

