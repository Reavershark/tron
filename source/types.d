module types;

struct Vector2
{
    int x, y;

    Vector2 opBinary(string op)(Vector2 rhs)
    {
        static if (op == "+")
        {
            x += rhs.x;
            y += rhs.y;
            return this;
        }
        else static if (op == "-")
        {
            x -= rhs.x;
            y -= rhs.y;
            return this;
        }
        else static assert(0, "Operator "~op~" not implemented");
    }

    Vector2 opBinary(string op)(int rhs)
    {
        static if (op == "+")
        {
            x += rhs;
            y += rhs;
            return this;
        }
        else static if (op == "-")
        {
            x -= rhs;
            y -= rhs;
            return this;
        }
        else static assert(0, "Operator "~op~" not implemented");
    }
}

unittest
{
    immutable Vector2 a = Vector2(2, 4);
    immutable Vector2 b = Vector2(1, 0);

    assert(a + b == Vector2(3, 4));
    assert(a + 2 == Vector2(4, 6));
}