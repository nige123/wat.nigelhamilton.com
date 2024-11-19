unit module WAT::CLI;
use LLM::DWIM;


#| find out what this code does  
multi sub MAIN ($filename_or_code) is export {

    # limit the number of tokens to process - allow for the prompt and response
    my $token-limit          = %*ENV{'WAT_MAX_TOKENS'}          // 3700;    # convervative limit
    my $response-char-limit  = %*ENV{'WAT_MAX_RESPONSE_CHARS'}  // 600; 
    
    my $program-content      = $filename_or_code.IO.e 
                             ?? slurp $filename_or_code 
                             !! $filename_or_code;

    # keep the prompt short and sweet
    my $prompt = q:to"PROMPT";
    
    You are an expert programmer. 
    Produce friendly, simple, structured output. 
    Summarise the following code for a new programmer.
    Limit the response to less than $response-char-limit characters. 
    Highlight how to use this code:

    PROMPT

    # truncate the program content to the token limit
    $program-content = $program-content.substr(0, $token-limit - ($prompt.chars + $response-char-limit));

    return 'No code to process.' unless $program-content;

    # call the LLM::DWIM module
    say "\n";
    say dwim $prompt ~ $program-content;
    say "\n";

}


#| show this help
multi sub MAIN ('help') is export {
    USAGE();
}


#| configure defaults
multi sub MAIN ('config') is export {
    CONFIG();
}


sub CONFIG is export {

    say q:to"CONFIG";

    wat - set the following config to change LLM settings
    
    Config:
    
        See LLM::DWIM to swap LLMs. 

        Set the environment variables to change token limits:
        
            WAT_MAX_TOKENS              -- limit the number of tokens used per request (default: 3400)
            WAT_MAX_RESPONSE_CHARS      -- limit the length of response (default: 600)    

    CONFIG
    
}


sub USAGE is export {

    say q:to"USAGE";

    wat - does this code do? LLM-powered utility for quickly understanding code.

    Usage:

        wat <filename>              -- summarise what the program does
        wat "$some-code.here();"    -- explain what some code does
        
        wat config                  -- change LLM settings
        wat help                    -- show this help
        
    USAGE
    
}

