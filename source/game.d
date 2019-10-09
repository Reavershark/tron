module game;
 
import types;

interface ITronGame
{
    void restart();
    bool tick();
    void setDirection(int playerId, string direction);
    bool[Vector2] getGrid();
}

struct Player
{
    Vector2 position;
    Vector2 direction;

    bool isAlive = true;

    this(Vector2 position, Vector2 direction)
    {
        this.position = position;
        this.direction = direction;
    }
}
 
class TronGame : ITronGame
{
    private:
    size_t playerCount;
    Player[] players;
 
    bool[Vector2] grid; // True means filled, false/unset means empty
    Vector2 dimensions;
 
    Vector2[size_t] defaultPositions;
    Vector2[size_t] defaultDirections;

    // Init functions
    void setGridSize(Vector2 dimensions)
    {
        this.dimensions = dimensions;
        defaultPositions[0] = Vector2(dimensions.x/4, dimensions.y/2);
        defaultPositions[1] = Vector2(dimensions.x*3/4, dimensions.y/2);
        defaultDirections[0] = Vector2(1, 0);
        defaultDirections[1] = Vector2(-1, 0);
    }

    void resetGrid()
    {
        players = null;
        foreach(i; 0..playerCount)
            players ~= Player(defaultPositions[i], defaultDirections[i]);
        drawPlayersToGrid();
    }
 
    public this(size_t playerCount = 2, Vector2 dimensions = Vector2(96, 64))
    {
        setGridSize(dimensions);
        this.playerCount = playerCount;
        resetGrid();
    }

    public void restart()
    {
        resetGrid();
    }
 
    // Update functions
    public bool tick()
    {
        foreach(ref player; players)
        {
            if(player.isAlive)
                player.position = player.position + player.direction;
            if(player.position in grid)
                if(grid[player.position]) // Throws range violation if not in grid
                    player.isAlive = false;
        }
        drawPlayersToGrid();

        // False on game end
        bool continueGame = false;
        foreach(player; players)
            continueGame = continueGame || player.isAlive;
        return continueGame;
    }

    void drawPlayersToGrid()
    {
        foreach(player; players)
            grid[player.position] = true;
    }

    // Input
    public void setDirection(int playerId, string direction)
    {
        if (players[playerId].isAlive)
            switch(direction)
            {
                default:
                    break;
                case "left":
                    players[playerId].direction = Vector2(-1, 0);
                    break;
                case "up":
                    players[playerId].direction = Vector2(0, -1);
                    break;
                case "right":
                    players[playerId].direction = Vector2(1, 0);
                    break;
                case "down":
                    players[playerId].direction = Vector2(0, 1);
                    break;
            }
    }

    // Getters

    public bool[Vector2] getGrid()
    {
        return grid;
    }
}