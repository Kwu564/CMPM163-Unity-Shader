using UnityEngine;
using System.Collections;
using System;

public class Scale : MonoBehaviour
{

    // Use this for initialization
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
      // Widen the object by 0.1
      transform.localScale += new Vector3( 0.003F * (float)(Math.Sin(Time.fixedTime * 3.0)), 0.005F * (float)(Math.Sin(Time.fixedTime * 3.0)), 0.0F);
      //transform.Rotate(Vector3.right * Time.deltaTime * 3.0f);

    }
}

