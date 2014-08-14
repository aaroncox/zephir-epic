namespace Epic\Iterator;

class Document implements \SeekableIterator, \RecursiveIterator
{
  protected _document;
  protected _position;
  protected _properties;
  protected _init;
  protected _counter;

  public function __construct(document)
  {
    let this->_document = document;
    let this->_properties = document->getPropertyKeys();
    let this->_position = current(this->_properties);
    reset(this->_properties);
  }

  public function getDocument()
  {
    return this->_document;
  }

  public function seek(position)
  {
    let this->_position = position;

    if !this->valid() {
      throw new \OutOfBoundsException("invalid seek position (position)");
    }
  }

  public function current()
  {
    return this->getDocument()->getProperty(this->key());
  }

  public function key()
  {
    return this->_position;
  }

  public function next()
  {
    next(this->_properties);
    let this->_position = current(this->_properties);
    let this->_counter = this->_counter + 1;
  }

  public function rewind()
  {
    reset(this->_properties);
    let this->_position = current(this->_properties);
  }

  public function valid()
  {
    return in_array(this->key(), this->_properties, true);
  }

  public function hasChildren()
  {
    return (this->current() instanceof Epic\Document);
  }

  public function getChildren()
  {
    return this->current()->getIterator();
  }
}