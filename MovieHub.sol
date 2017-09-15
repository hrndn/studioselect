pragma solidity ^0.4.10;

import "./Movie.sol";

/**
 * Hub for the hub/spokes pattern.
 * This hub creates/stops/resumes Movies.
 */ 
contract MovieHub is Owned{
    
    event LogNewMovie     (address producer, address Movie, string producerName);
    event LogMovieStarted (address producer, address Movie);
    event LogMovieStopped (address producer, address Movie);
    event LogMovieNewOwner(address Movie, address oldOwner, address newOwner);
    
    address[]                public MovieContracts;
    mapping(address => bool) public existingMovies;
    uint                     public hub_fee;

    modifier MovieExists(address Movie) {
        require(existingMovies[Movie]);
        _;
    }
    
    function getMoviesCount()
    constant
    returns(uint)
    {
        return MovieContracts.length;
    }
    
    function newMovie(uint _duration, uint _goal, address _producer) 
    onlyOwner
    external
    returns (address movieAddress)
    {
        Movie newMovie = new Movie(_duration,_goal,_producer, this.hub_fee);
        MovieContracts.push(newMovie);
        existingMovies[newMovie] = true;
        LogNewMovie(msg.sender, newMovie, producer);
        return newMovie;        
    }
    
    
    
    function changeMovieOwner(address Movie, address newOwner) 
    onlyOwner
    MovieExists(Movie)
    returns (bool success)
    {
        Movie.changeOwner(newOwner);
        LogMovieNewOwner(Movie, msg.sender, newOwner);
        return true;        
    }

    function changeMovieProducer(address Movie, address newProducer) 
    onlyOwner
    MovieExists(Movie)
    returns (bool success)
    {
        address oldProducer = Movie.producer
        Movie.producer = newProducer;
        LogMovieNewProducer(trustedMovie, oldProducer, newProducer);
        return true;        
    }

}