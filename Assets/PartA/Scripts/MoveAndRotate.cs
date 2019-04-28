
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveAndRotate : MonoBehaviour
{
    public float moveSpeed;
    public float rotationSpeed;
    public Vector3 rotationVector;

    // Update is called once per frame
    void Update()
    {
        transform.Rotate(rotationVector, rotationSpeed * Time.deltaTime);
    }
}
