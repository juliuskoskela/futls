{
  description = "Futls: Some flake utilities...";

  outputs = { self }: {
    lib = import ./lib;
    templates = import ./templates;
  };
}
