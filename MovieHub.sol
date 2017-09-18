pragma solidity ^0.4.10;

import "./Movie.sol";

/**
 * Hub for the hub/spokes pattern.
 * This hub creates/stops/resumes Movies.
 */ 
contract MovieHub is Stoppable{
    
    event LogNewMovie     (address producer, address Movie, string producerName);
    event LogMovieStarted (address producer, address Movie);
    event LogMovieStopped (address producer, address Movie);
    event LogMovieNewOwner(address Movie, address oldOwner, address newOwner);
    
    address[]                public movieContracts;
    mapping(address => bool) public movieExists;
    uint                     public hub_fee;

    struct TokenStruct {
        uint totalSupply;
        mapping (address => uint) tokenHolders;
    }

    mapping(address => TokenStruct) public tokenStruct;      

    modifier ifMovieExists(address Movie) {
        require(movieExists[Movie]);
        _;
    }
    
    function getMoviesCount()
    constant
    returns(uint movieCount)
    {
        return movieContracts.length;
    }
    
    function newMovie(uint _duration, uint _goal, address _producer) 
    onlyOwner
    external
    returns (address movieAddress)
    {
        Movie newMovie = new Movie(_duration,_goal,_producer, this.hub_fee);
        movieContracts.push(newMovie);
        movieExists[newMovie] = true;
        LogNewMovie(msg.sender, newMovie, producer);
        tokenStruct[newMovie].totalSupply = newMovie.movieToken.totalSupply;
        tokenStruct[newMovie].tokenHolders = newMovie.tokenHolders;

        return newMovie;        
    }
    
    
    function stopMovie(address movie)
        onlyOwner
        ifMovieExists(movie)
        returns (bool success)
        {
        Movie trustedMovie = Movie(movie);
        LogMovieStopped(msg.sender,movie);
        return (trustedMovie.runSwitch(false));

        }

    function startMovie(address movie)
        onlyOwner
        ifMovieExists(movie)
        returns (bool success)
        {
        Movie trustedMovie = Movie(movie);
        LogMovieStarted(msg.sender,movie);
        return (trustedMovie.runSwitch(true));

        }


    function changeMovieOwner(address movie, address newOwner) 
    onlyOwner
    ifMovieExists(movie)
    returns (bool success)
    {
        Movie trustedMovie = Movie(movie);
        LogMovieNewOwner(movie, msg.sender, newOwner);
        return (trustedMovie.changeOwner(newOwner));
    }

    function changeMovieProducer(address movie, address newProducer) 
    onlyOwner
    ifMovieExists(movie)
    returns (bool success)
    {
        Movie trustedMovie = Movie(movie);
        LogMovieNewProducer(trustedMovie, oldProducer, newProducer);
        return (trustedMovie.changeProducer(newProducer));     
    }

}