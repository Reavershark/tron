module game;
 
import types;

interface ITronGame
{
    void restart();
    bool tick();
    void setDirection(int playerId, string direction);
    string getGrid();
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
        int alivePlayers = 0;
        foreach(player; players)
            if (player.isAlive)
                alivePlayers++;
        return alivePlayers >= 2;
    }

    void drawPlayersToGrid()
    {
        foreach(player; players)
            grid[player.position] = true;
    }

    // Input
    public void setDirection(int playerId, string direction)
    {
        Player* player = &players[playerId];
        if (players[playerId].isAlive)
        {
            if (direction == "left" && player.direction != Vector2(1, 0))
                player.direction = Vector2(-1, 0);
            else if (direction == "up" && player.direction != Vector2(0, 1))
                player.direction = Vector2(0, -1);
            else if (direction == "right" && player.direction != Vector2(-1, 0))
                player.direction = Vector2(1, 0);
            else if (direction == "down" && player.direction != Vector2(0, -1))
                player.direction = Vector2(0, 1);
        }
    }

    // Getters

    public string getGrid()
    {
        string s;
        foreach(y; 0..dimensions.y)
        {
            foreach(x; 0..dimensions.x)
            {
                auto coord = Vector2(x, y);
                if (coord in grid && grid[coord]) // Throws range violation if not in grid
                    s ~= "1";
                else
                    s ~= "0";
            }
            s ~= "\n";
        }
        return s;
    }
}
