public record Geo(string Lat, string Lng);

public record Address(string Street, string City, string Zipcode, Geo Geo);

public record User(int Id, string Name, string Username, string Email, Address Address);
